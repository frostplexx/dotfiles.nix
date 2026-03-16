#!/usr/bin/env fish

set root $argv[1]
set expanded_root (eval echo $root)

set repos (fd -H -t d --max-depth 4 -g ".git" $expanded_root \
    | string replace -r '/.git/?$' '' \
    | string replace "$expanded_root/" '' \
    | sort)

if test (count $repos) -eq 0
    echo -e "\033[31m\033[0m  No repos found under $root"
    exit 1
end

set selected (printf '%s\n' $repos | fzf \
    --prompt="  Open in browser > " \
    --height=40% \
    --border \
    --border-label="   Open Repo ")

if test -z "$selected"
    echo -e "\033[2m  Aborted.\033[0m"
    exit 0
end

set full "$expanded_root/$selected"

# Get the remote URL
set remote_url (git -C $full remote get-url origin 2>/dev/null)

if test -z "$remote_url"
    echo -e "\033[31m\033[0m  No remote 'origin' found for $selected"
    exit 1
end

# Normalise to https URL
set web_url $remote_url
set web_url (string replace -r '^git@([^:]+):' 'https://$1/' $web_url)
set web_url (string replace -r '^ssh://git@' 'https://' $web_url)
set web_url (string replace -r '^git://' 'https://' $web_url)
set web_url (string replace -r '\.git$' '' $web_url)

echo -e "\033[34m\033[0m  Opening \033[1m$web_url\033[0m"
open $web_url
