#!/usr/bin/env fish

set -l current_src (SwitchAudioSource -c)

if [ "$current_src" = "MacBook Pro Speakers" ]
    SwitchAudioSource -s "SMSL M-3 Desktop DAC"
    # Send notification
    osascript -e 'display notification "Switched to SMSL M-3 Desktop DAC" with title "Audio Source Switched"'
else
    SwitchAudioSource -s "MacBook Pro Speakers"
    osascript -e 'display notification "Switched to MacBook Pro Speakers" with title "Audio Source Switched"'
end
