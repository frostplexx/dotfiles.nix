function wololo
    set -g HOST "up.int.kuipr.de"
    
    # Open Tailscale
    if not pgrep -x Tailscale >/dev/null
        echo "Connecting to tailnet..."
        open -g -a Tailscale
        # Connect to tailnet
        tailscale up
        # Wait until it connected
        tailscale wait
    end
    
    set -g identity (op read "op://Personal/UpSnap/email")
    set -g password (op read "op://Personal/UpSnap/password")
    
    set -g jwt (curl -s -X POST "https://$HOST/api/collections/_superusers/auth-with-password" -H "Content-Type: application/json" -d "{\"identity\":\"$identity\",\"password\":\"$password\"}" | jq -r '.token')
    
    if test -z "$jwt"
        echo "Auth token is empty. Failed to authenticate. Exiting."
        exit 1
    end
    
    set -g devices (curl -s -X GET "https://$HOST/api/collections/devices/records" -H "Authorization: Bearer $jwt")
    
    set -g selected (echo $devices | jq -r '.items[].name' | fzf)
    
    if test -z "$selected"
        exit 0
    end
    
    set -g device_id (echo $devices | jq -r --arg name "$selected" '.items[] | select(.name == $name) | .id')
    
    echo "Booting: $selected ($device_id)"
    
    
    curl -s -X GET "https://$HOST/api/upsnap/wake/$device_id" -H "Authorization: Bearer $jwt" > /dev/null
    
    while true 
        set -l device_status (curl -s -X GET "https://$HOST/api/collections/devices/records/$device_id" -H "Authorization: Bearer $jwt" | jq -r ".status")
    
        if test "$device_status" = "online"
            echo "$selected is online"
            break
        end
    
        sleep 1
    end
end


function connect_ollama 
    # Check if eduVPN is running and connect if not connected
    if ! pgrep -x "eduVPN" > /dev/null
        echo "Starting eduVPN..."
        # Wait for eduVPN to establish connection (adjust sleep time as needed)
        open -a "eduVPN"
    end
    # Port is on 11434
    echo "Connecting to Ollama on port 11434..."
    ssh -N -L 11434:localhost:11434 GPU_Server_Students
end

function llamacode
    set -l fzf_opts \
        --height 100% \
        --layout reverse \
        --border rounded \
        --prompt "model> " \
        --pointer "▶" \
        --marker "✓" \
        --info inline \
        --exact \
        --preview "ollama show {1}" \
        --preview-window right:60%:wrap \
        --bind "ctrl-/:toggle-preview" \
        --bind "ctrl-j:down,ctrl-k:up" \
        --color "header:italic:underline,pointer:green,marker:yellow"
    
    set -l header (ollama list | head -1)
    set -l selection (ollama list | tail -n +2 | fzf --header "$header" $fzf_opts)
    set -l selected_model (string split -f1 ' ' $selection)
    echo "Selected model: $selected_model"
    
    
    ollama launch claude --model $selected_model -y

end



function open-man-page
    set -l token (commandline -t)
    if test -n "$token"
        man $token &
        commandline -f repaint
    end
end


function compress_to_webp
    if test (count $argv) -ne 1
        echo (set_color red)"Usage: compress_to_webp <input>"(set_color normal)
        return 1
    end

    set input_file $argv[1]
    set output_file (string replace -r '\.png$' '' $input_file)
    magick $input_file -quality 50 $output_file--WebP.webp
end


function project_selector
    set selected (repodex jump)

    if test -n "$selected"
        # Create new Kitty tab and activate direnv before starting neovim
        cd $selected
        direnv allow
    end
end

function wake
    if test (uname) = Linux
        # Check current DPMS status
        set status (xset -q | grep 'DPMS is' | awk '{ print $3 }')

        # Toggle DPMS based on current status
        if test "$status" = Enabled
            xset -dpms
            dunstify 'Screen suspend is disabled.'
        else
            xset +dpms
            dunstify 'Screen suspend is enabled.'
        end
    else
        printf '  Keeping PC awake...'
        caffeinate -d -i -m -s
    end
end

function manf
    /usr/bin/man -k . 2>/dev/null | fzf --preview 'man {1}' --preview-window=right:70%:wrap | awk '{print $1}' | xargs man
end

# Function to kill processes with fzf (Fish shell with Nerd Font icons - macOS compatible)
function fkill
    set -l selection (ps -axo pid,pcpu,pmem,ucomm | \
        awk 'NR>1 {
            pid=$1; cpu=$2; mem=$3;
            $1=""; $2=""; $3="";
            cmd=substr($0, 4);
            short_cmd=length(cmd) > 80 ? substr(cmd, 1, 77) "..." : cmd;
            printf "%s\t%s\t%s\t%s\n", short_cmd, cpu, mem, pid
        }' | \
        sort -k2 -nr | \
        awk 'BEGIN {print "Name\tCPU%\tMEM%\tPID"} {print}' | \
        column -t -s \t | \
        fzf --multi \
            --header-lines=1 \
            --height=90% \
            --border=rounded \
            --prompt="  Kill process  " \
            --marker="󰄬 " \
            --color="header:italic:underline,label:blue,prompt:cyan,pointer:red,marker:green" \
            --bind="ctrl-r:reload(ps -axo pid,pcpu,pmem,ucomm | awk 'NR>1 {
                pid=\$1; cpu=\$2; mem=\$3;
                \$1=\"\"; \$2=\"\"; \$3=\"\";
                cmd=substr(\$0, 4);
                short_cmd=length(cmd) > 80 ? substr(cmd, 1, 77) \"...\" : cmd;
                printf \"%s\\t%s\\t%s\\t%s\\n\", short_cmd, cpu, mem, pid
            }' | sort -k2 -nr | awk 'BEGIN {print \"Name\\tCPU%\\tMEM%\\tPID\"} {print}' | column -t -s \t)"
    )
    if test -n "$selection"
        set -l pids (echo "$selection" | awk '{print $NF}' | grep -E '^[0-9]+$')
        if test -n "$pids"
            set_color green
            echo " Selected processes:"
            set_color normal
            for pid in $pids
                set -l name (ps -p "$pid" -o ucomm= 2>/dev/null; or echo "unknown")
                echo "   $(set_color red)$(set_color normal) PID $pid — $(set_color yellow)$name"
                set_color normal
            end
            echo
            read -P " Are you sure you want to kill these processes? [y/N] " -n 1 confirm
            echo
            if string match -qi y "$confirm"
                for pid in $pids
                    kill $pid 2>/dev/null
                end
                set_color green
                echo " Done!"
            else
                set_color yellow
                echo " Cancelled."
                set_color normal
            end
        end
    else
        echo " No process selected."
    end
end
