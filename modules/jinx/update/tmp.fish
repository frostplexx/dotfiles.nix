#!/usr/bin/env fish

function flake-diff --description "Compare flake.lock between commits and show GitHub commits" --argument-names flake_dir
    # Set default directory to current if not provided
    if test -z "$flake_dir"
        set flake_dir "."
    end

    # Change to the specified directory
    set original_dir (pwd)
    if not cd "$flake_dir" 2>/dev/null
        echo "Error: Cannot access directory '$flake_dir'" >&2
        return 1
    end

    # Check if we're in a git repository
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Error: '$flake_dir' is not in a git repository" >&2
        cd "$original_dir"
        return 1
    end

    # Check if flake.lock exists
    if not test -f flake.lock
        echo "Error: flake.lock not found in '$flake_dir'" >&2
        cd "$original_dir"
        return 1
    end

    # Check for required tools
    if not command -q jq
        echo "Error: jq is required but not installed" >&2
        cd "$original_dir"
        return 1
    end

    if not command -q curl
        echo "Error: curl is required but not installed" >&2
        cd "$original_dir"
        return 1
    end

    # Get the previous commit's flake.lock
    set prev_commit (git rev-parse HEAD~1)
    set current_commit (git rev-parse HEAD)
    set temp_dir (mktemp -d)
    set prev_flake_lock "$temp_dir/flake.lock.prev"
    set current_flake_lock "$temp_dir/flake.lock.current"

    # Check if working tree is clean (no uncommitted changes to flake.lock)
    if git diff --quiet flake.lock 2>/dev/null
        # Working tree is clean, compare HEAD vs HEAD~1
        if not git show "$prev_commit:flake.lock" >"$prev_flake_lock" 2>/dev/null
            echo "Error: Could not find flake.lock in previous commit" >&2
            rm -rf "$temp_dir"
            cd "$original_dir"
            return 1
        end
        if not git show "$current_commit:flake.lock" >"$current_flake_lock" 2>/dev/null
            echo "Error: Could not find flake.lock in current commit" >&2
            rm -rf "$temp_dir"
            cd "$original_dir"
            return 1
        end
        echo "Comparing flake.lock in '$flake_dir' between $prev_commit and $current_commit..."
    else
        # Working tree has changes, compare HEAD vs working tree
        if not git show "$prev_commit:flake.lock" >"$prev_flake_lock" 2>/dev/null
            echo "Error: Could not find flake.lock in previous commit" >&2
            rm -rf "$temp_dir"
            cd "$original_dir"
            return 1
        end
        cp flake.lock "$current_flake_lock"
        echo "Comparing flake.lock in '$flake_dir' between $prev_commit and current working tree..."
    end
    echo

    # Parse both flake.lock files and compare (only GitHub repos that are actual flakes)
    set current_inputs (jq -r '.nodes | to_entries[] | select(.value.locked != null and .value.locked.type == "github" and (.value.flake != false)) | "\(.key):\(.value.locked.owner // ""):\(.value.locked.repo // ""):\(.value.locked.rev // "")"' "$current_flake_lock" 2>/dev/null)
    set prev_inputs (jq -r '.nodes | to_entries[] | select(.value.locked != null and .value.locked.type == "github" and (.value.flake != false)) | "\(.key):\(.value.locked.owner // ""):\(.value.locked.repo // ""):\(.value.locked.rev // "")"' "$prev_flake_lock" 2>/dev/null)

    if test $status -ne 0
        echo "Error: Failed to parse flake.lock files" >&2
        rm -rf "$temp_dir"
        cd "$original_dir"
        return 1
    end

    # Create associative arrays using fish arrays
    set -l current_revs
    set -l prev_revs

    # Parse current inputs
    for input in $current_inputs
        set parts (string split ':' "$input")
        set name "$parts[1]"
        set owner "$parts[2]"
        set repo "$parts[3]"
        set rev "$parts[4]"

        if test -n "$owner" -a -n "$repo" -a -n "$rev"
            set current_revs $current_revs "$name|$owner|$repo|$rev"
        end
    end

    # Parse previous inputs
    for input in $prev_inputs
        set parts (string split ':' "$input")
        set name "$parts[1]"
        set owner "$parts[2]"
        set repo "$parts[3]"
        set rev "$parts[4]"

        if test -n "$owner" -a -n "$repo" -a -n "$rev"
            set prev_revs $prev_revs "$name|$owner|$repo|$rev"
        end
    end

    # Function to fetch commits between two revisions
    function fetch_commits --argument-names owner repo old_rev new_rev
        # echo "  Fetching commits from GitHub API..."

        # Get commits between revisions using GitHub API
        set api_url "https://api.github.com/repos/$owner/$repo/compare/$old_rev...$new_rev"
        set response (curl -s -H "Accept: application/vnd.github.v3+json" "$api_url")

        if test $status -ne 0
            echo "  ❌ Failed to fetch commits from GitHub API"
            return 1
        end

        # Check if the response contains an error
        set error_message (echo "$response" | jq -r '.message // empty' 2>/dev/null)
        if test -n "$error_message"
            echo "  ❌ GitHub API error: $error_message"
            return 1
        end

        # Parse and display commits - handle multi-line messages properly
        set commit_count (echo "$response" | jq -r '.commits | length' 2>/dev/null)

        if test "$commit_count" = 0 -o "$commit_count" = null
            echo "  📭 No commits found"
            return 0
        end

        echo "$(set_color yellow)   Changes:$(set_color normal)"

        # Process each commit individually to handle multi-line messages
        for i in (seq 0 (math "$commit_count - 1"))
            set commit_data (echo "$response" | jq -r ".commits[$i] | \"\(.sha[0:7])|\(.commit.author.date)|\(.commit.message)\"" 2>/dev/null)

            if test -z "$commit_data"
                continue
            end

            # Split only on the first two pipes to preserve message content
            set sha (echo "$commit_data" | cut -d'|' -f1)
            set date (echo "$commit_data" | cut -d'|' -f2)
            set message (echo "$commit_data" | cut -d'|' -f3-)

            # Format date (just month and day)
            set formatted_date (date -d "$date" "+%b %d" 2>/dev/null; or echo (string sub -l 10 "$date"))

            # Get only the first line of the commit message and clean it up
            set first_line (echo "$message" | head -n1 | string trim)

            # Skip empty messages
            if test -z "$first_line"
                continue
            end

            # Truncate if too long
            set display_message "$first_line"
            if test (string length "$first_line") -gt 90
                set display_message (string sub -l 87 "$first_line")"..."
            end

            echo "    • $display_message"
            # echo "       ($sha, $formatted_date)"
        end
        echo
    end

    # Find updated inputs
    set found_updates false

    for current_entry in $current_revs
        set current_parts (string split '|' "$current_entry")
        set name "$current_parts[1]"
        set owner "$current_parts[2]"
        set repo "$current_parts[3]"
        set current_rev "$current_parts[4]"

        # Find matching entry in previous revs
        set prev_rev ""
        for prev_entry in $prev_revs
            set prev_parts (string split '|' "$prev_entry")
            if test "$prev_parts[1]" = "$name"
                set prev_rev "$prev_parts[4]"
                break
            end
        end

        # Check if revision changed
        if test -n "$prev_rev" -a "$prev_rev" != "$current_rev"
            set found_updates true

            echo "$(set_color blue)󰚰 Updated: $(set_color -o blue)$name$(set_color normal)"
            echo "$(set_color yellow)   Repository:$(set_color normal) https://github.com/$owner/$repo"
            # echo "   Previous:   $prev_rev"
            # echo "   Current:    $current_rev"
            echo "$(set_color yellow)   Compare:$(set_color normal)    https://github.com/$owner/$repo/compare/$prev_rev...$current_rev"

            # Fetch and display commits
            fetch_commits "$owner" "$repo" "$prev_rev" "$current_rev"
        end
    end

    # Check for new inputs
    for current_entry in $current_revs
        set current_parts (string split '|' "$current_entry")
        set name "$current_parts[1]"
        set owner "$current_parts[2]"
        set repo "$current_parts[3]"
        set current_rev "$current_parts[4]"

        # Check if this input exists in previous
        set found_in_prev false
        for prev_entry in $prev_revs
            set prev_parts (string split '|' "$prev_entry")
            if test "$prev_parts[1]" = "$name"
                set found_in_prev true
                break
            end
        end

        if not $found_in_prev
            set found_updates true
            echo "$(set_color green) New input: $(set_color -o green)$name$(set_color normal)"
            echo "$(set_color yellow)  Repository:$(set_color normal) https://github.com/$owner/$repo"
            echo "$(set_color yellow)  Revision:  $(set_color normal) $current_rev"
            echo "$(set_color yellow)  Link:      $(set_color normal) https://github.com/$owner/$repo/tree/$current_rev"
            echo
        end
    end

    # Check for removed inputs
    for prev_entry in $prev_revs
        set prev_parts (string split '|' "$prev_entry")
        set name "$prev_parts[1]"
        set owner "$prev_parts[2]"
        set repo "$prev_parts[3]"

        # Check if this input exists in current
        set found_in_current false
        for current_entry in $current_revs
            set current_parts (string split '|' "$current_entry")
            if test "$current_parts[1]" = "$name"
                set found_in_current true
                break
            end
        end

        if not $found_in_current
            set found_updates true
            echo "$(set_color red) Removed input:$(set_color -o red) $name$(set_color normal)"
            echo "$(set_color red)   Repository:$(set_color normal) https://github.com/$owner/$repo"
            echo
        end
    end

    if not $found_updates
        echo "$(set_color yellow)No changes found in flake inputs.$(set_color normal)"
    end

    # Cleanup
    rm -rf "$temp_dir"
    cd "$original_dir"
end

# Make the function available when script is sourced
flake-diff $argv
