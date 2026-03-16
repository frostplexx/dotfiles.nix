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

set total (count $repos)
echo -e "\n\033[1m  Fetching $total repos...\033[0m\n"

set ok 0
set failed 0

for repo in $repos
    set full "$expanded_root/$repo"
    printf "  \033[2m%-55s\033[0m" "$repo"

    set output (git -C $full fetch --all --prune 2>&1)
    if test $status -eq 0
        set ok (math $ok + 1)
        echo -e "\033[32m \033[0m"
    else
        set failed (math $failed + 1)
        echo -e "\033[31m \033[0m"
        echo -e "    \033[2m$output\033[0m"
    end
end

echo ""
echo -e "  \033[2m─────────────────────────────────\033[0m"
echo -e "   \033[32m$ok fetched\033[0m  \033[31m$failed failed\033[0m  \033[2m/ $total total\033[0m"
echo ""
