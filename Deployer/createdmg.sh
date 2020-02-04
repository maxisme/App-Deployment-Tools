#!/bin/bash

if [[ "$2" == "" ]]
then
	echo "params = (output [.dmg], source)"
	exit
fi

vol="$(basename "$2")"
name="${vol%.*}"

# defaults write com.apple.finder AppleShowAllFiles YES # show hidden files
# echo "Restarting Finder to show hidden files"
# sudo killall Finder

test -f "$1" && rm "$1"
create-dmg/create-dmg \
--volname "$name" \
--background "create-dmg/bg.png" \
--window-pos 200 120 \
--window-size 625 300 \
--icon-size 80 \
--icon "$vol" 20 190 \
--hide-extension "$name" \
--app-drop-link 30 190 \
"$1" \
"$2/"

# defaults write com.apple.finder AppleShowAllFiles NO # hide hidden files
# echo "Restarting Finder to NOT show hidden files"
# sudo killall Finder
