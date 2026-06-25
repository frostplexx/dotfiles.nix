# SSH mount helpers — fuse-t-sshfs + fzf
# Install: cp sshm.fish ~/.config/fish/conf.d/sshm.fish
# Commands: sshm (mount)  |  sshu (unmount)

function sshm --description "Mount remote SSH folder via fuse-t-sshfs"
    set -l ssh_hosts ~/.ssh/hosts

    # --- hosts from ~/.ssh/hosts ---
    set -l hosts (grep -E "^Host " $ssh_hosts 2>/dev/null \
        | grep -v '[*?]' \
        | awk '{print $2}')

    if test (count $hosts) -eq 0
        echo "no hosts in $ssh_hosts" >&2
        return 1
    end

    # --- pick host ---
    set -l host (printf '%s\n' $hosts \
        | fzf --prompt "host > " \
              --height 40% \
              --border \
              --no-sort)
    test -z "$host"; and return 0

    # --- fetch remote dirs, preview with ls ---
    echo "connecting to $host..." >&2
    set -l dirs (ssh -q -F $ssh_hosts -o ConnectTimeout=5 $host \
        'find ~ -maxdepth 4 -type d 2>/dev/null | sort' 2>/dev/null)
    test (count $dirs) -eq 0; and begin; echo "✗ could not list dirs on $host" >&2; return 1; end
    set -l remote_dir (printf '%s\n' $dirs \
        | fzf --prompt "dir > " \
              --height 80% \
              --border \
              --preview "ssh -q -F $ssh_hosts $host 'ls -1 {}' 2>/dev/null" \
              --preview-window "right:40%:wrap")
    test -z "$remote_dir"; and return 0

    # --- build local mount point ~/mnt/<host>/<path_underscored> ---
    set -l safe (string replace -a "/" "_" (string sub --start 2 $remote_dir))
    set -l mnt ~/mnt/$host/$safe
    mkdir -p $mnt

    # --- mount (macOS: no idmap=user; pass hosts file so sshfs resolves port/identity) ---
    sshfs "$host:$remote_dir" $mnt \
        -o reconnect \
        -o ServerAliveInterval=15 \
        -o "ssh_command=ssh -F $ssh_hosts"

    if test $status -eq 0
        echo "✓ $host:$remote_dir → $mnt"
        # open in yazi if available
        if command -q yazi
            read -l -P "open in yazi? [y/N] " _open
            string match -qi "y" $_open
            and yazi $mnt
        end
    else
        rmdir $mnt 2>/dev/null
        echo "✗ mount failed" >&2
        return 1
    end
end


function sshu --description "Unmount a fuse-t-sshfs mount interactively"
    # macOS mount format: "X on /path (type, opts)" — fuse-t mounts as nfs/smb locally
    set -l mnt (mount \
        | awk '{print $3}' \
        | grep "^$HOME/mnt" \
        | fzf --prompt "unmount > " \
              --height 40% \
              --border)
    test -z "$mnt"; and return 0

    umount $mnt
    if test $status -eq 0
        rmdir $mnt 2>/dev/null
        echo "✓ unmounted $mnt"
    else
        echo "✗ failed — try: umount -f $mnt" >&2
        return 1
    end
end
