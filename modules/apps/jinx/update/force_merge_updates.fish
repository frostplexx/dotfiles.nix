#!/usr/bin/env fish




set -l pull_requests (gh pr list --state open --json number,title,headRefName,baseRefName \
  | jq -r '.[] | "\(.number)\t\(.title)\t\(.headRefName) → \(.baseRefName)"')

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


for pr_number in $pr_numbers
  gh pr merge $pr_number --squash --admin
end
