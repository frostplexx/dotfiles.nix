#!/usr/bin/env fish

echo -e "\n\033[1m  repodex doctor\033[0m\n"

set all_ok 1

function check
    set name $argv[1]
    set cmd  $argv[2]

    printf "  \033[2m%-20s\033[0m" "$name"
    if command -q $cmd
        set ver (command $cmd --version 2>/dev/null | head -1)
        echo -e "\033[32m \033[0m  \033[2m$ver\033[0m"
    else
        echo -e "\033[31m \033[0m  \033[31mnot found\033[0m"
        set -g all_ok 0
    end
end

check "git"  git
check "fd"   fd
check "fzf"  fzf
check "eza"  eza
check "fish" fish

echo ""
echo -e "  \033[2m─────────────────────────────────\033[0m"

if test $all_ok -eq 1
    echo -e "   \033[32mAll dependencies satisfied\033[0m"
else
    echo -e "   \033[31mSome dependencies are missing\033[0m"
    exit 1
end

echo ""
