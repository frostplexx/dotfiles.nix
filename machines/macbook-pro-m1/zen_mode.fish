#!/usr/bin/env fish

# State file to track toggle status
set state_file ~/.cache/floating_window_state

# Function to hide desktop icons
function hide_desktop_icons
    defaults write com.apple.finder CreateDesktop -bool false
    killall Finder
end

# Function to show desktop icons
function show_desktop_icons
    defaults write com.apple.finder CreateDesktop -bool true
    killall Finder
end

# Function to set window to floating with 16:10 aspect ratio
function set_floating_window
    # Get the focused window ID and set it as a variable
    set -g window_id (aerospace list-windows --focused --json | jq -r ".[].\"window-id\"")

    # Set the window to floating layout
    aerospace layout floating

    # Get screen dimensions
    set screen_info (osascript -e 'tell application "Finder" to get bounds of window of desktop')
    set screen_bounds (echo $screen_info | tr ',' '\n' | string trim)
    set screen_width (echo $screen_bounds[3])
    set screen_height (echo $screen_bounds[4])

    # Calculate 16:10 aspect ratio dimensions (85% of screen height)
    set target_height (math "$screen_height * 0.80")
    set target_width (math "$target_height * 16 / 10")

    # Calculate center position
    set x_pos (math "($screen_width - $target_width) / 2")
    set y_pos (math "($screen_height - $target_height) / 2")

    # Move and resize the window using osascript
    osascript -e "
    tell application \"System Events\"
        set frontApp to name of first application process whose frontmost is true
        tell application process frontApp
            tell front window
                set position to {$x_pos, $y_pos}
                set size to {$target_width, $target_height}
            end tell
        end tell
    end tell
    "
end

# Function to restore window to tiled layout
function restore_tiled_window
    # Get the focused window ID
    set -g window_id (aerospace list-windows --focused --json | jq -r ".[].\"window-id\"")

    # Set the window back to tiled layout
    aerospace layout tiling
end

# Main toggle logic
if test -f $state_file
    # Currently in floating mode, restore to tiled
    restore_tiled_window
    show_desktop_icons
    rm $state_file
    echo "Restored to tiled mode with desktop icons"
else
    # Currently in tiled mode, switch to floating
    set_floating_window
    hide_desktop_icons
    touch $state_file
    echo "Switched to floating mode, desktop icons hidden"
end
