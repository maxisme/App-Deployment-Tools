on run (volumeName)
	tell application "Finder"
		tell disk (volumeName as string)
			open
			
			set theXOrigin to 200
			set theYOrigin to 120
			set theWidth to 480
			set theHeight to 400
			
			set theBottomRightX to (theXOrigin + theWidth)
			set theBottomRightY to (theYOrigin + theHeight)
			set dsStore to "\"" & "/Volumes/" & volumeName & "/" & ".DS_STORE\""
			
			tell container window
				set current view to icon view
				set toolbar visible to false
				set statusbar visible to false
				set the bounds to {theXOrigin, theYOrigin, theBottomRightX, theBottomRightY}
				set statusbar visible to false
				set position of every item to {theBottomRightX + 300, 20}
			end tell
			
			set opts to the icon view options of container window
			tell opts
				set icon size to 100
				set text size to 12
				set arrangement to not arranged
			end tell
			set background picture of opts to file ".background:bg.png"
			
			-- Application Link Clause
			set position of item "Applications" to {373, 190}
			set name of item "Applications" to " "
			
			-- Positioning
			set position of item "appname.app" to {108, 180}
			
			-- Hiding
			set the extension hidden of item "appname" to true
			
			close
			open
			
			update without registering applications
			-- Force saving of the size
			delay 1
			
			tell container window
				set statusbar visible to false
				set the bounds to {theXOrigin, theYOrigin, theBottomRightX - 10, theBottomRightY - 10}
			end tell
			set viewOptions to the icon view options of container window
			set arrangement of viewOptions to not arranged
			update without registering applications
		end tell
		
		delay 1
		
		tell disk (volumeName as string)
			tell container window
				set statusbar visible to false
				set the bounds to {theXOrigin, theYOrigin, theBottomRightX, theBottomRightY}
			end tell
			
			update without registering applications
		end tell
		
		--give the finder some time to write the .DS_Store file
		delay 3
		
		set waitTime to 0
		set ejectMe to false
		repeat while ejectMe is false
			delay 1
			set waitTime to waitTime + 1
			
			if (do shell script "[ -f " & dsStore & " ]; echo $?") = "0" then set ejectMe to true
		end repeat
		log "waited " & waitTime & " seconds for .DS_STORE to be created."
	end tell
end run
