#!/bin/bash

if [[ "$1" == "" ]]
then
    echo "You have not specified the app name"
    exit
fi

if [ -d "$1" ]; then
	echo "$1 already a directory"
	exit
fi

mkdir "$1"
cd "$1"

img="icon.png"
img_b="logo.png"
og="og_logo.png"
ico="icon.ico"
menu_ico="app_menu_icon.png"

img_background="icon_bg.png"

cp "../logo.psd" "logo.psd"
convert logo.psd[2] $img_b
convert logo.psd[1] -background transparent -gravity center -scale 1024x1024 -extent 1024x1024 $img # and add background chanel

#############
# app icons #
#############

# create menu bar icon
convert $img_b -background transparent -gravity center -scale 75x75 -extent 100x100 $menu_ico

# make image have background for .dmg and add padding
convert $img -background transparent -gravity center -scale 940x940 \
-extent 1024x1024 -channel a -evaluate add 1% +channel $img_background

# create AppIcon.appiconset
iconPath="Assets.xcassets/AppIcon.appiconset"
rm -rf $iconPath
mkdir -p $iconPath
cp '../Contents.json' 'Assets.xcassets/AppIcon.appiconset/'
convert $img_background -resize 16x16 $iconPath/icon_16.png
convert $img_background -resize 32x32 $iconPath/icon_16@2x.png
convert $img_background -resize 32x32 $iconPath/icon_32.png
convert $img_background -resize 64x64 $iconPath/icon_32@2x.png
convert $img_background -resize 128x128 $iconPath/icon_128.png
convert $img_background -resize 256x256 $iconPath/icon_128@2x.png
convert $img_background -resize 256x256 $iconPath/icon_256.png
convert $img_background -resize 512x512 $iconPath/icon_256@2x.png
convert $img_background -resize 512x512 $iconPath/icon_512.png
cp $img_background $iconPath/icon_512@2x.png

#######
# web #
#######

# meta logo
# 620x620 is due to fb share logo
convert $img -background transparent -gravity center -scale 620x620 -extent 1024x1024 $og

#ico (tab icon)
sizes=( 16 32 48 128 256 )

t="tmp"
rm -rf "$t"
mkdir "$t"

for size in "${sizes[@]}"
do
	path="$t/${size}.png"
	convert $img -scale $size $path
	cmd="${cmd}${path} "
done
convert $cmd $ico

# move to Images
mkdir "images"
mv $ico "images/"
mv $img_b "images/"
mv $og "images/"

## clean up
rm -rf $t $img_background $img
