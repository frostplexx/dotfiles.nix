
function gitStatus
    echo "Repositories with unpushed commits:"
    find . -maxdepth 4 -type d -name '.git' | while read -l gitdir
        set -l repo (string replace -r '/?\.git$' '' -- "$gitdir")
        if git -C "$repo" status | string match -q '*is ahead of*'
            echo "$repo"
        end
    end

    echo
    echo "Repositories with changed/deleted/added/untracked files:"
    find . -type d -name '.git' | while read -l gitdir
        set -l repo (string replace -r '/?\.git$' '' -- "$gitdir")
        set -l changes (git -C "$repo" status --short)

        if test (count $changes) -gt 0
            printf '\n\033[1m%s\033[m\n' "$repo"
            printf '%s\n' $changes
        end
    end
end
