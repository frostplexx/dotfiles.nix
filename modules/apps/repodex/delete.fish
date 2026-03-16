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

# Let user pick one with fzf
set selected (printf '%s\n' $repos | fzf \
    --prompt="  Delete repo > " \
    --height=40% \
    --border \
    --border-label=" 󰆴  Delete Repo " \
    --color="border:red,label:red")

if test -z "$selected"
    echo -e "\033[2m  Aborted.\033[0m"
    exit 0
end

set full_path "$expanded_root/$selected"

# Check for uncommitted changes
if not git -C $full_path diff --quiet 2>/dev/null; or not git -C $full_path diff --cached --quiet 2>/dev/null
    echo -e "\033[31m\033[0m  '$selected' has uncommitted changes. Refusing to delete."
    exit 1
end

# Check for untracked files
set untracked (git -C $full_path ls-files --others --exclude-standard 2>/dev/null)
if test -n "$untracked"
    echo -e "\033[31m\033[0m  '$selected' has untracked files. Refusing to delete."
    exit 1
end

# Check for unpushed commits on any branch
set unpushed (git -C $full_path log --branches --not --remotes --oneline 2>/dev/null)
if test -n "$unpushed"
    echo -e "\033[31m\033[0m  '$selected' has unpushed commits. Refusing to delete."
    exit 1
end

# Confirm
read --prompt "echo -e '\033[31m󰆴\033[0m  Delete $full_path? [y/N] '" confirm
if test "$confirm" != y -a "$confirm" != Y -a "$confirm" != yes -a "$confirm" != YES
    echo -e "\033[2m  Aborted.\033[0m"
    exit 0
end

rm -rf $full_path
echo -e "\033[32m\033[0m  Deleted $selected"
