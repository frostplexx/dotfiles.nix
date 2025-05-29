#!/usr/bin/env fish
# Get the focused window ID and set it as a variable
set -g window_id (aerospace list-windows --focused --json | jq -r ".[].\"window-id\"")
# Set the window to floating layout
aerospace layout floating

# Get screen dimensions
set screen_info (osascript -e 'tell application "Finder" to get bounds of window of desktop')
set screen_bounds (echo $screen_info | tr ',' '\n' | string trim)
set screen_width (echo $screen_bounds[3])
set screen_height (echo $screen_bounds[4])

# Calculate 16:10 aspect ratio dimensions (80% of screen height)
set target_height (math "$screen_height * 0.8")
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

open "cleanshot://capture-window"
