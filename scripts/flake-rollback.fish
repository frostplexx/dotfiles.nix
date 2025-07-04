#!/usr/bin/env fish

# Check if we're in a flake directory
if not test -f flake.lock
    echo "$(set_color red) Error: flake.lock not found in current directory"
    exit 1
end

# Check if git is available and we're in a git repo
if not command -v git >/dev/null 2>&1
    echo "$(set_color red) Error: git is required but not found"
    exit 1
end

if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
    echo "$(set_color red) Error: not in a git repository"
    exit 1
end

# Check if fzf is available
if not command -v fzf >/dev/null 2>&1
    echo "$(set_color red) Error: fzf is required but not found"
    exit 1
end

# Check if jq is available
if not command -v jq >/dev/null 2>&1
    echo "$(set_color red) Error: jq is required but not found"
    exit 1
end

# Function to get changed inputs
function get_changed_inputs
    set current_lock flake.lock

    # Get the previous version of flake.lock from git
    set prev_lock (mktemp)
    if not git show HEAD:$current_lock >$prev_lock 2>/dev/null
        echo "Error: Could not get previous version of flake.lock from git"
        rm -f $prev_lock
        exit 1
    end

    # Compare the locks and find changed inputs
    set changed_inputs

    # Get all input names from current lock
    set inputs (jq -r '.nodes.root.inputs | keys[]' $current_lock)

    for input in $inputs
        if test -z "$input"
            continue
        end

        # Get current and previous revisions
        set current_rev (jq -r --arg input "$input" '
            .nodes.root.inputs[$input] as $node_name |
            .nodes[$node_name].locked.rev // empty
        ' $current_lock)

        set prev_rev (jq -r --arg input "$input" '
            .nodes.root.inputs[$input] as $node_name |
            .nodes[$node_name].locked.rev // empty
        ' $prev_lock 2>/dev/null; or echo "")

        # If revisions are different, add to changed inputs
        if test "$current_rev" != "$prev_rev" -a -n "$current_rev"
            set short_current (string sub -l 8 $current_rev)
            set short_prev (string sub -l 8 $prev_rev)
            set changed_inputs $changed_inputs "$input ($short_prev -> $short_current)"
        end
    end

    rm -f $prev_lock

    if test (count $changed_inputs) -eq 0
        echo "No changed inputs found in flake.lock"
        exit 0
    end

    printf '%s\n' $changed_inputs
end

# Function to revert selected inputs
function revert_inputs
    set selected_inputs $argv

    if test (count $selected_inputs) -eq 0
        echo "No inputs selected for reversion"
        exit 0
    end

    echo "Reverting selected inputs..."

    # Get the previous flake.lock
    set prev_lock (mktemp)
    git show HEAD:flake.lock >$prev_lock

    # Create a new flake.lock by merging current and previous
    set new_lock (mktemp)
    cp flake.lock $new_lock

    for selected in $selected_inputs
        # Extract input name (everything before the first space and parenthesis)
        set input_name (string split ' (' $selected)[1]

        echo "Reverting $input_name..."

        # Get the node name for this input
        set node_name (jq -r --arg input "$input_name" '.nodes.root.inputs[$input]' $prev_lock)

        if test "$node_name" = null
            echo "$(set_color yellow) Warning: Could not find $input_name in previous lock file"
            continue
        end

        # Copy the node from previous lock to new lock
        set node_data (jq --arg node "$node_name" '.nodes[$node]' $prev_lock)

        # Update the new lock file
        jq --arg node "$node_name" --argjson data "$node_data" '
            .nodes[$node] = $data
        ' $new_lock >$new_lock.tmp
        mv $new_lock.tmp $new_lock
    end

    # Replace the current flake.lock with the updated one
    cp $new_lock flake.lock

    # Clean up
    rm -f $prev_lock $new_lock

    echo "$(set_color green) Successfully reverted "(count $selected_inputs)" input(s)$(set_color normal)"
    echo "You can now try rebuilding your configuration"
end

# Main script
function main
    echo "Analyzing flake.lock changes..."

    # Get changed inputs
    set changed_inputs_output (get_changed_inputs)

    if test -z "$changed_inputs_output"
        echo "No changes detected in flake.lock"
        exit 0
    end

    # Use fzf to select inputs to revert
    set selected_inputs (printf '%s\n' $changed_inputs_output | fzf --multi --header="󱄅 Select inputs to revert (use Tab to select multiple, Enter to confirm)")

    if test (count $selected_inputs) -eq 0
        echo "No inputs selected. Exiting."
        exit 0
    end

    # Confirm the selection
    echo ""
    echo "You selected the following inputs to revert:"
    for input in $selected_inputs
        echo "$(set_color red)  -  $input$(set_color normal)"
    end
    echo ""

    read -P "Are you sure you want to revert these inputs? (y/N): " -n 1 confirm
    echo ""

    if not string match -qi 'y*' $confirm
        echo "Operation cancelled."
        exit 0
    end

    # Revert the selected inputs
    revert_inputs $selected_inputs
end

# Run main function
main $argv
