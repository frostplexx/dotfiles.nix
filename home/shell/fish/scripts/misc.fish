function project_selector
    set selected (ghq list | fzf --height 40% --border --preview 'ls -la ~/Developer/{}' --preview-window right:50%)
    if test -n "$selected"
        cd ~/Developer/$selected && vim
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
