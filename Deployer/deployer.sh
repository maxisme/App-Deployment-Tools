#!/bin/bash

dev_team="3H49MXS325"
# `security find-identity -v -p codesigning` ->> "Mac Developer"
# can be recreated with xcode preferences > + > mac Developer
sign_key="92FE8FE7E7A291030E292B8129AD99F72E65F585"

if [[ -z "$4" ]]
then
	echo "Not entered all params"
	exit
fi

#INITIAL VARIABLES THAT NEED TO BE CUSTOMISED
project_name="$1"
project_type="$2"
work_name="$3"
domain="$4"

#CALCULATED INITIAL VARIABLES
project_dir="/Users/maxmitch/Documents/work/${work_name}/"
xcode_project=$project_dir$project_name$project_type
plist=$project_dir"buildOptions.plist"
xcarchive=$project_dir"tmp.xcarchive"
app="$project_dir$project_name.app"
info_plist="$project_dir$project_name/Info.plist"
dmg_project_output="/Users/maxmitch/Documents/work/${domain}/public_html/${project_name}.dmg"
scp_command="scp '"$dmg_project_output"' root@${domain}:/var/www/${domain}/public_html/"
sparkle_path="https://${domain}/version.php"

#countdown function
function countDown {
	rm -rf "$project_dir$project_name.app" "$xcarchive" "$plist"

	secs=$((20))
	while [ $secs -gt 0 ]; do
	   echo -ne "Will exit in $secs\033[0K\r"
	   sleep 1
	   : $((secs--))
	done
	exit
}

# check if outstanding commits
live_dir="$(pwd)"
cd "$project_dir"
if [[ `git status --porcelain` ]]; then
	echo -e "\n\nYou have uncommited files!!! Please push first."
	exit
fi

# check versions
live_version=$(curl -v --silent $sparkle_path 2>&1 | sed -ne '/title/{s/.*<title>Version\ \(.*\)<\/title>.*/\1/p;q;}')
actual_version=$(xcrun agvtool what-version | sed -n '2p' | xargs)

echo "Online version is $live_version. Deploying version $actual_version"
read -p "Continue? " answer

cd "$live_dir"

#create temp .plist file
echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>method</key><string>developer-id</string><key>teamID</key><string>$dev_team</string></dict></plist>" > "$plist"

#build project
type="-project"
#Change '-project' to '-workspace'. Depending on if $project_type is '.xcodeproj' or '.xcworkspace'.
if [[ $project_type == ".xcworkspace" ]]; then
	type="-workspace"
fi
xcodebuild $type "$xcode_project" -scheme "$project_name" -configuration Release clean archive -archivePath "$xcarchive" DEVELOPMENT_TEAM=$dev_team

#check if last command succeeded
if [ $? -ne 0 ]; then
	countDown
fi

xcodebuild -exportArchive -archivePath "$xcarchive" -exportOptionsPlist "$plist" -exportPath "$project_dir"

#check if last command succeeded
if [ $? -ne 0 ]; then
	countDown
fi

bash createdmg.sh "$dmg_project_output" "${app}/"

#remove temp files used in build
echo "cleaning up..."
rm -rf "$app" "$xcarchive" "$plist" "${project_dir}DistributionSummary.plist" "${project_dir}ExportOptions.plist"

# #commit
cd "$project_dir"
git tag -a "v$actual_version" -m "Releasing version $actual_version"
git push origin master

#upload to website
eval $scp_command

echo -e "------------\n\nREMEMBER TO NOW UPDATE version.php WITH THE NEW VERISON ($actual_version)\n\n------------"
