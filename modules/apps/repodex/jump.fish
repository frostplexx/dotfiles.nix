#!/usr/bin/env fish

set root $argv[1]
set expanded_root (eval echo $root)

set selected (fd -H -t d --max-depth 4 -g ".git" $expanded_root \
    | string replace -r '/.git/?$' '' \
    | string replace "$expanded_root/" '' \
    | sort \
    | fzf \
        --prompt="  Jump to repo > " \
        --height=80% \
        --border \
        --border-label="   Repodex " \
        --preview "bash $(dirname (status filename))/jump_preview.sh $expanded_root {}" \
        --preview-window=right:50%)

if test -z "$selected"
    exit 0
end

echo "$expanded_root/$selected"
