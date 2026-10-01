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
