#!/usr/bin/env fish

# Fish translation of update-flake-revs with syntax and runtime fixes.
# - Avoid Bash-style ${var} expansions that cause fish to parse bracket indices
# - Use printf for escape sequences and color output
# - Properly handle default directory argument for fd
# - Fix variable assignments and parsing of owner|repo|rev matches

function _printf_color --description 'Helper to print colored text'
    printf "%b\n" "$argv"
end

set RED '\033[0;31m'
set GREEN '\033[0;32m'
set YELLOW '\033[0;33m'
set BLUE '\033[0;34m'
set BOLD '\033[1m'
set RESET '\033[0m'

# Build banner strings using printf to avoid fish index parsing of brackets
set SUCCESS (printf "%s%s%s%s" $GREEN $BOLD "[SUCCESS]" $RESET)
set ERROR (printf "%s%s%s%s" $RED $BOLD "[ERROR]" $RESET)
set WARN (printf "%s%s%s%s" $YELLOW $BOLD "[WARN]" $RESET)
set INFO (printf "%s%s%s%s" $BLUE $BOLD "[INFO]" $RESET)

function check_dependencies
    set -l missing_deps
    if not type -q jq
        set missing_deps $missing_deps jq
    end
    if not type -q fd
        set missing_deps $missing_deps fd
    end
    if test (count $missing_deps) -ne 0
        printf "%b\n" "$RED Error: Missing required dependencies:$RESET"
        for d in $missing_deps
            printf "%s\n" $d
        end
        printf "%s\n" "Please install the missing dependencies and try again."
        exit 1
    end
end

function show_change --argument-names old new
    if test "$old" != "$new"
        printf "%b\n" "$RED- $old$RESET"
        printf "%b\n" "$GREEN+ $new$RESET"
    else
        printf "%s\n" "  $old (unchanged)"
    end
end

function extract_value --argument-names line
    # Use printf to preserve the exact line and then extract the first quoted string
    printf "%s\n" "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p'
end

function update_repo --argument-names file owner repo current_rev
    printf "%b\n" "$BLUE Checking $owner/$repo in $file$RESET"

    set -l latest_rev (curl -s "https://api.github.com/repos/$owner/$repo/commits/main" | jq -r '.sha')
    printf "%s\n" $latest_rev

    if test "$latest_rev" = "$current_rev"
        printf "%b\n" "$GREEN Already at latest revision$RESET"
        return 0
    end

    set -l url "https://github.com/$owner/$repo/archive/$latest_rev.tar.gz"

    set -l new_sha256 (nix-prefetch-url --unpack "$url")
    set -l new_sha256_base64 (nix-hash --type sha256 --to-sri "$new_sha256")

    printf "Current revision: %s\n" $current_rev
    printf "Latest revision:  %s\n" $latest_rev
    printf "New SHA256 (base64): %s\n" $new_sha256_base64

    cp "$file" "$file.bak"

    if grep -q "hash =" "$file"
        set hash_attr hash
    else
        set hash_attr sha256
    end

    # Update rev using awk (preserve original approach)
    awk -v owner="$owner" -v repo="$repo" -v old_rev="$current_rev" -v new_rev="$latest_rev" '
    {
        if ($0 ~ "owner = \"" owner "\"") {
            owner_found = 1
        } else if (owner_found && $0 ~ "repo = \"" repo "\"") {
            repo_found = 1
        } else if (owner_found && repo_found && $0 ~ "rev = \"" old_rev "\"") {
            sub(old_rev, new_rev)
            owner_found = 0
            repo_found = 0
        }
        print
    }' "$file.bak" > "$file"

    printf "%b\n" "Updating Hash..."

    awk -v owner="$owner" -v repo="$repo" -v new_hash="$new_sha256_base64" -v hash_attr="$hash_attr" '
    {
        if ($0 ~ "owner = \"" owner "\"") {
            owner_found = 1
            print
            next
        }
        if (owner_found && $0 ~ "repo = \"" repo "\"") {
            repo_found = 1
            print
            next
        }
        if (owner_found && repo_found && $0 ~ hash_attr " = ") {
            sub(/"[^"]*"/, "\"" new_hash "\"")
            owner_found = 0
            repo_found = 0
        }
        print
    }' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

    rm -f "$file.bak"

    printf "%b\n" "$GREEN Successfully updated $owner/$repo$RESET"
end

function find_and_update_repos --argument-names dir
    # Default to current directory if none provided
    if test -z "$dir"
        set dir .
    end

    # fd pattern '.' with path $dir
    for file in (fd --extension nix . $dir)
        printf "%b\n" "$BLUE Scanning $file$RESET"

        set -l matches
        set in_block 0
        set owner ''
        set repo ''
        set rev ''

        while read -l line
            if echo $line | grep -q "fetchFromGitHub"
                set in_block 1
                set owner ''
                set repo ''
                set rev ''
            else if test $in_block -eq 1
                if echo $line | grep -q "owner ="
                    set owner (extract_value "$line")
                else if echo $line | grep -q "repo ="
                    set repo (extract_value "$line")
                else if echo $line | grep -q "rev ="
                    set rev (extract_value "$line")
                else if echo $line | grep -q "};"
                    if test -n "$owner" -a -n "$repo" -a -n "$rev"
                        set matches $matches "$owner|$repo|$rev"
                    end
                    set in_block 0
                end
            end
        end < "$file"

        for m in $matches
            set parts (string split '|' $m)
            set owner $parts[1]
            set repo $parts[2]
            set rev $parts[3]
            if test -n "$owner" -a -n "$repo" -a -n "$rev"
                update_repo "$file" "$owner" "$repo" "$rev"
            end
        end
    end
end

# Main
check_dependencies

printf "%b\n" "$BLUE Checking for available updates...$RESET"

# Determine target dir from argv (if supplied)
set target_dir .
if test (count $argv) -ge 1
    set target_dir $argv[1]
end

find_and_update_repos $target_dir

printf "%b\n" "$GREEN Done updating all repositories$RESET"

