#!/usr/bin/env fish

set FILE "/tmp/scratchpad.md"
set KITTY_TITLE "Scratchpad"
set NEOVIM_CMD "nvim -u /Users/daniel/dotfiles.nix/machines/macbook-pro-m1/minimal.vim $FILE"

function get_scratchpad_id
    # Get window ID more reliably using string manipulation to handle JSON properly
    set window_id (aerospace list-windows --all --json | jq -r '.[] | select(."window-title" == "Scratchpad") | ."window-id"')
    echo $window_id
end

function focus_notepad
    # Save current workspace before focusing notepad
    set current_workspace (aerospace list-workspaces --focused)
    echo $current_workspace > /tmp/current_workspace

    # Check if scratchpad already exists
    set window_id (get_scratchpad_id)
    
    if test -n "$window_id"
        # If it exists, just focus it
        aerospace focus --window-id $window_id
    else
        # Launch new kitty instance with scratchpad
        kitty --title $KITTY_TITLE -T $KITTY_TITLE fish -c "$NEOVIM_CMD" &
        # Small delay to ensure window is created
        # sleep 0.5
    end
    
    # Get the window ID (again if newly created) and fullscreen it
    set window_id (get_scratchpad_id)
    aerospace fullscreen on --window-id $window_id
end

function notepad_focused
    test (aerospace list-windows --focused --format "%{window-title}") = "$KITTY_TITLE"
    return $status
end

function unfocus_notepad
    set window_id (get_scratchpad_id)
    
    if test -n "$window_id"
        # Turn off fullscreen first
        aerospace fullscreen off --window-id $window_id
        
        # Get process ID of kitty running the scratchpad
        set kitty_pid (ps -ax | grep "kitty.*$KITTY_TITLE" | grep -v grep | awk '{print $1}')
        
        # Kill the kitty process properly
        if test -n "$kitty_pid"
            kill $kitty_pid
        end
    end
    
    # Return to the original workspace
    if test -f "/tmp/current_workspace"
        aerospace workspace (cat /tmp/current_workspace)
    end
end

# Main script logic
if notepad_focused
    unfocus_notepad
else
    focus_notepad
end
