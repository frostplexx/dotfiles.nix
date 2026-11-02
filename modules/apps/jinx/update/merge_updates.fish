#!/usr/bin/env fish

set -g STATUS_SCRIPT "$HOME/dotfiles.nix/modules/apps/jinx/lib/status.sh"

set -l pull_requests (gh pr list --state open --json number,title,headRefName,baseRefName \
  | jq -r '.[] | "\(.number)\t\(.title)\t\(.headRefName) → \(.baseRefName)"')

$STATUS_SCRIPT blocked question "Select pull requests to merge"
set -l selected (printf '%s\n' $pull_requests \
  | fzf \
    --multi \
    --delimiter='\t' \
    --with-nth='1,2' \
    --preview='echo -e "PR #{1}\nBranch: {3}"' \
    --preview-window='down:3:wrap' \
    --header='↑↓ navigate  TAB multi-select  ENTER confirm' \
    --prompt='PRs › ' \
    --pointer='▶' \
    --marker='✓' \
    --color='header:italic,prompt:bold' \
    --height=40% \
    --border=rounded \
    --info=inline)

set -l pr_numbers (printf '%s\n' $selected | awk -F'\t' '{print $1}')

# early exist when no PRs are selected
if test -z "$pr_numbers"
    exit 0
end

$STATUS_SCRIPT working "Merging pull requests"

for pr_number in $pr_numbers
  $STATUS_SCRIPT working "Merging PR #$pr_number"
  gh pr merge $pr_number --squash --admin
end
