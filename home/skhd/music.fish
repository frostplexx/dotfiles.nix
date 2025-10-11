#!/usr/bin/env fish

set -l command $argv[1]

switch $command
        case play
            osascript -e 'tell application "Music" to play' >/dev/null 2>&1
        
        case pause
            osascript -e 'tell application "Music" to pause' >/dev/null 2>&1
        
        case stop
            osascript -e 'tell application "Music" to stop' >/dev/null 2>&1
        
        case next
            osascript -e 'tell application "Music" to next track' >/dev/null 2>&1
        
        case prev previous
            osascript -e 'tell application "Music" to previous track' >/dev/null 2>&1
        
        case shuffle
            if test (count $argv) -eq 2
                switch $argv[2]
                    case on true
                        osascript -e 'tell application "Music" to set shuffle enabled to true'
                        echo "Shuffle enabled"
                    case off false
                        osascript -e 'tell application "Music" to set shuffle enabled to false'
                        echo "Shuffle disabled"
                    case '*'
                        echo "Usage: ./music.fish shuffle [on|off]"
                end
            else
                set current_shuffle (osascript -e 'tell application "Music" to return shuffle enabled')
                echo "Shuffle is currently: $current_shuffle"
            end
        
        case repeat
            if test (count $argv) -eq 2
                switch $argv[2]
                    case off
                        osascript -e 'tell application "Music" to set song repeat to off'
                        echo "Repeat off"
                    case one
                        osascript -e 'tell application "Music" to set song repeat to one'
                        echo "Repeat one"
                    case all
                        osascript -e 'tell application "Music" to set song repeat to all'
                        echo "Repeat all"
                    case '*'
                        echo "Usage: ./music.fish repeat [off|one|all]"
                end
            else
                set current_repeat (osascript -e 'tell application "Music" to return song repeat')
                echo "Repeat is currently: $current_repeat"
            end
        
        case volume vol
            if test (count $argv) -eq 2
                osascript -e "tell application \"Music\" to set sound volume to $argv[2]"
                echo "Volume set to $argv[2]"
            else
                set current_volume (osascript -e 'tell application "Music" to return sound volume')
                echo "Current volume: $current_volume"
            end
        
        case status info
            set player_state (osascript -e 'tell application "Music" to return player state' 2>/dev/null)
            if test -z "$player_state"
                echo "Music app is not running"
                return
            end
            
            if test "$player_state" = "stopped"
                echo "No track selected"
                return
            end
            
            set track_name (osascript -e 'tell application "Music" to return name of current track' 2>/dev/null)
            set artist_name (osascript -e 'tell application "Music" to return artist of current track' 2>/dev/null)
            
            if test -n "$track_name" -a -n "$artist_name"
                echo "Now playing: $track_name by $artist_name"
                echo "Player state: $player_state"
            else
                echo "Player state: $player_state"
            end
        
        case help h
            echo "Apple Music Control Script"
            echo ""
            echo "Commands:"
            echo "  play           - Play music"
            echo "  pause          - Pause music"
            echo "  stop           - Stop music"
            echo "  next           - Next track"
            echo "  prev/previous  - Previous track"
            echo "  shuffle [on|off] - Toggle shuffle or show status"
            echo "  repeat [off|one|all] - Set repeat mode or show status"
            echo "  volume/vol [0-100] - Set volume or show current"
            echo "  status/info    - Show current track info"
            echo "  help/h         - Show this help"
        
        case '*'
            echo "Unknown command: $command"
            echo "Use './music.fish help' for available commands"
end