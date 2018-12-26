repeat
	set readyForInstall to 1
	try
		-- Checks whether fwGUI is running and sets fwProcess to returned value
		set fwProcess to (do shell script "ps -arxo state,comm | grep fwGUI.app")
		-- Checks for filesets pending activation and sets activateStatus to the number of filesets pending activation
		set activateStatus to (do shell script "/usr/local/bin/fwcontrol client status | grep activateFiles | wc -l")
	end try
	
	try
		set fwProcess to fwProcess as string
		set activateStatus to activateStatus as number
		set readyForInstall to 0
	end try
	
	if readyForInstall is 0 and activateStatus is greater than or equal to 1 then
		-- Initial progress information
		set countDown to 120
		set progress total steps to 120
		set progress completed steps to 0
		set progress description to "All apps will be closed in 2 minutes for system updates to be applied."
		set progress additional description to "After apps have closed, click Start Installation to begin the process immediately."
		
		repeat with a from 1 to 120
			-- Update progress details
			-- set progress additional description to "Preparing update: " & a & " of " & "60"
			set aText to a as string
			if aText ends with 0 then
				tell application "FileWave Update Launcher" to activate
			end if
			-- Increment the progress
			set progress completed steps to a
			delay 1
		end repeat
		set progress completed steps to 0
		
		tell application "System Events" to set openApps to name of every application process whose background only is false and name is not "FileWave Update Launcher" and name is not "FileWave Kiosk"
		try
			tell application "owncloud"
				quit
			end tell
		end try
		
		try
			repeat with openApp in openApps
				tell application openApp
					-- Tell application to quit if it doesn't have any open windows
					quit
				end tell
			end repeat
		end try
		
		do shell script "/usr/local/bin/fwcontrol fwgui restart"
		
		exit repeat
		
	else
		return "Not ready yet"
	end if
end repeat