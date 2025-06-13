#!/usr/bin/env fish

function switch-audio
    # Fetch all devices
    set devices (SwitchAudioSource -a -f json | jq -r '"\(.name)\t\(.type)\t\(.uid)"')

    # Get current output device UID
    set current_uid (SwitchAudioSource -c -t output -f json | jq -r '.uid')

    # Format for fzf: add a ✓ to the selected device
    set display_list
    for line in $devices
        set name (echo $line | cut -f1)
        set type (echo $line | cut -f2)
        set uid (echo $line | cut -f3)
        set id (echo $line | cut -f4)

        if test "$type" = output
            if test "$uid" = "$current_uid"
                set display_list $display_list "✓ $name"
            else
                set display_list $display_list "  $name"
            end
        end
    end

    # Use fzf to select a device
    set selected_device (printf "%s\n" $display_list | fzf --prompt="Select audio output: " | string trim)

    # Exit if nothing selected
    if test -z "$selected_device"
        return
    end

    # Remove leading ✓ or spaces to get name
    set device_name (string trim (string replace -r '^[✓ ]+ *' '' -- $selected_device))

    # Switch to selected device
    SwitchAudioSource -s "$device_name" >/dev/null
    echo -e "🔈 Switched to: $device_name"
end

switch-audio
