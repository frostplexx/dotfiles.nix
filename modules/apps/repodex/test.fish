function repodex
    # Run the TUI and save the output after it exits
    ./target/debug/repodex $argv > /tmp/repodex-selected.txt

    # Read the selected path
    set selected_path (cat /tmp/repodex-selected.txt)

    # If a path was returned, cd into it
    if test -n "$selected_path"
        cd "$selected_path"
    end

    # Clean up
    rm /tmp/repodex-selected.txt
end
