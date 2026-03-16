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

set dirty_count 0
set clean_count 0

echo ""

for repo in $repos
    set full "$expanded_root/$repo"

    set unstaged  (git -C $full diff --name-only 2>/dev/null)
    set staged    (git -C $full diff --cached --name-only 2>/dev/null)
    set untracked (git -C $full ls-files --others --exclude-standard 2>/dev/null)
    set unpushed  (git -C $full log --branches --not --remotes --oneline 2>/dev/null)

    set has_issues 0
    if test -n "$unstaged" -o -n "$staged" -o -n "$untracked" -o -n "$unpushed"
        set has_issues 1
    end

    if test $has_issues -eq 1
        set dirty_count (math $dirty_count + 1)
        echo -e "  \033[1m$repo\033[0m"

        if test -n "$unstaged"
            echo -e "    \033[33m\033[0m  Unstaged changes"
        end
        if test -n "$staged"
            echo -e "    \033[34m\033[0m  Staged changes"
        end
        if test -n "$untracked"
            echo -e "    \033[2m\033[0m  Untracked files"
        end
        if test -n "$unpushed"
            echo -e "    \033[35m\033[0m  "(count (string split \n $unpushed))" unpushed commit(s)"
        end
        echo ""
    else
        set clean_count (math $clean_count + 1)
    end
end

set total (count $repos)
echo -e "  \033[2m─────────────────────────────────\033[0m"
echo -e "   \033[32m$clean_count clean\033[0m  \033[31m$dirty_count dirty\033[0m  \033[2m/ $total total\033[0m"
echo ""
