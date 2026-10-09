function project_selector
    set selected (repodex jump)

    if test -n "$selected"
        # Create new Kitty tab and activate direnv before starting neovim
        cd $selected
        direnv allow
    end
end
