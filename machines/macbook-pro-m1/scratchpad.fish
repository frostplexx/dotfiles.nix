#!/usr/bin/env fish

set APP_ID "md.obsidian"

set -g CURRENT_WORKSPACE 0

function focus_notepad
    open -a Obsidian
    set workspace (aerospace list-workspaces --focused)
    echo $workspace > /tmp/current_workspace
    aerospace fullscreen on --window-id (aerospace list-windows --all --json | jq .[] | jq 'select(."app-name" == "Obsidian") | ."window-id"')
end

function notepad_focused
    if test (aerospace list-windows --focused --format "%{app-bundle-id}") = "$APP_ID"
        return 0
    else
        return 1
    end
end

function unfocus_notepad
    aerospace fullscreen off --window-id (aerospace list-windows --all --json | jq .[] | jq 'select(."app-name" == "Obsidian") | ."window-id"')
    aerospace close
    aerospace workspace (cat /tmp/current_workspace)
end

if notepad_focused
    unfocus_notepad
else
    focus_notepad
end
