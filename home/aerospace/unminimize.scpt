#!/usr/bin/osascript

-- Check if we have accessibility permissions
try
    tell application "System Events"
        set runningApps to name of every application process whose background only is false
    end tell
on error
    display dialog "This script requires accessibility permissions. Please grant access in System Preferences > Security & Privacy > Privacy > Accessibility" buttons {"OK"} default button 1
    return "Permission denied"
end try

-- File to track the last restored window index
set stateFile to (path to temporary items folder as string) & "unminimize_state.txt"

-- Read the last index (if exists)
set lastIndex to 0
try
    set lastIndex to (read file stateFile as integer)
on error
    set lastIndex to 0
end try

-- Collect all minimized windows from all applications
set allMinimizedWindows to {}

repeat with appName in runningApps
    try
        tell application "System Events"
            tell process appName
                set minimizedWindows to every window whose value of attribute "AXMinimized" is true
                repeat with minWindow in minimizedWindows
                    try
                        -- Get window title for better identification
                        set windowTitle to value of attribute "AXTitle" of minWindow
                        set windowRecord to {appName:appName, windowRef:minWindow, windowTitle:windowTitle}
                        set end of allMinimizedWindows to windowRecord
                    on error
                        -- If we can't get title, still add it with generic info
                        set windowRecord to {appName:appName, windowRef:minWindow, windowTitle:"Unknown"}
                        set end of allMinimizedWindows to windowRecord
                    end try
                end repeat
            end tell
        end tell
    on error
        -- Skip apps that don't support window queries
    end try
end repeat

-- Check if we have any minimized windows
if (count of allMinimizedWindows) = 0 then
    -- Reset state file when no windows
    try
        set fileRef to (open for access file stateFile with write permission)
        write "0" to fileRef
        close access fileRef
    on error
        try
            close access fileRef
        end try
    end try
    return "No minimized windows found"
end if

-- Calculate next index (cycle through available windows)
set nextIndex to (lastIndex mod (count of allMinimizedWindows)) + 1

-- Save the new index for next run
try
    set fileRef to (open for access file stateFile with write permission)
    write (nextIndex as string) to fileRef
    close access fileRef
on error
    try
        close access fileRef
    end try
end try

-- Get the window to restore
set windowToRestore to item nextIndex of allMinimizedWindows
set targetApp to appName of windowToRestore
set targetWindow to windowRef of windowToRestore
set targetTitle to windowTitle of windowToRestore

-- Unminimize the selected window
try
    tell application "System Events"
        tell process targetApp
            set value of attribute "AXMinimized" of targetWindow to false
        end tell
    end tell

    -- Bring the application to front
    tell application targetApp to activate

    return "Unminimized window '" & targetTitle & "' from " & targetApp & " (" & nextIndex & " of " & (count of allMinimizedWindows) & ")"
on error errorMessage
    return "Error unminimizing window: " & errorMessage
end try
