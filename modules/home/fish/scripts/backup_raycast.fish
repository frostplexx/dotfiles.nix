function backup_raycast
    echo "Opening Raycast export settings dialog..."
    
    set download_folder "$HOME/Downloads"
    
    
    # Snapshot .rayconfig files that already exist before export
    set before (find "$download_folder" -maxdepth 1 -name "*.rayconfig" 2>/dev/null)
    
    open "raycast://extensions/raycast/raycast/export-settings-data"
    
    echo "Watching for new .rayconfig files in $download_folder..."
    
    set tmp /tmp/watch_raycast_{$fish_pid}.swift
    
    # kqueue watches the directory inode for writes (fires when entries are added/removed)
    # More reliable than FSEvents for rename-into-place patterns (which Raycast likely uses)
    begin
        echo 'import Foundation'
        echo 'guard let folder = ProcessInfo.processInfo.environment["WATCH_DIR"] else { exit(1) }'
        echo 'let fd = open(folder, O_EVTONLY)'
        echo 'let kq = kqueue()'
        echo 'var ke = kevent(ident: UInt(fd), filter: Int16(EVFILT_VNODE),'
        echo '                flags: UInt16(EV_ADD | EV_ENABLE | EV_CLEAR),'
        echo '                fflags: UInt32(NOTE_WRITE), data: 0, udata: nil)'
        echo 'kevent(kq, &ke, 1, nil, 0, nil)'
        echo 'while true {'
        echo '    var ev = kevent()'
        echo '    guard kevent(kq, nil, 0, &ev, 1, nil) > 0 else { continue }'
        echo '    let files = (try? FileManager.default.contentsOfDirectory(atPath: folder)) ?? []'
        echo '    for f in files where f.hasSuffix(".rayconfig") { print("\(folder)/\(f)"); exit(0) }'
        echo '}'
    end > $tmp
    
    set new_file (env WATCH_DIR="$download_folder" swift $tmp)
    rm -f $tmp
    
    if test -n "$new_file"; and not contains -- "$new_file" $before
        set filename "config.gz"
        echo "New Raycast settings file detected: $new_file"
        mv "$new_file" "$download_folder/$filename"
        gunzip -c "$download_folder/$filename" > "$download_folder/config"
        raycast-decrypt-config "$download_folder/config"
    
        rm -f "$download_folder/config"
    
        echo "Raycast settings decrypted and saved to config.json"
        mv "config.json" "$HOME/dotfiles.nix/modules/home/raycast/config.json"
    
        echo "Backup complete. You can now commit the updated config.json to your repository."
    end
end
