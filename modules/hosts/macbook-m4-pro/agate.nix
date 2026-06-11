_: {
  flake.darwinModules.agate = {
    defaults,
    lib,
    ...
  }:
    lib.mkIf defaults.settings.window_manager {
      services.agate = {
        enable = true;
        config =
          /*
          lua
          */
          ''
            -- agate-wm configuration.
            -- Loaded on startup from $WM_CONFIG, $XDG_CONFIG_HOME/agate/init.lua,
            -- ~/.config/agate/init.lua, or ./init.lua (this file, for development).

            -- Gaps and hyper-key definition.
            agate.config({
                gaps = 8,              -- space between tiles
                outer_gaps = 8,        -- inset from the screen edge
                accordion_padding = 20, -- stacked-window "peek": how far each window fans out
                -- "hyper" expands to this modifier set in keyspecs below.
                hyper = { "ctrl", "alt", "cmd" },
            })

            -- Focus movement (i3-style hjkl).
            agate.bind("hyper+h", function() agate.focus("left") end)
            agate.bind("hyper+j", function() agate.focus("down") end)
            agate.bind("hyper+k", function() agate.focus("up") end)
            agate.bind("hyper+l", function() agate.focus("right") end)

            -- Move the focused window to an adjacent slot.
            agate.bind("hyper+shift+h", "move left")
            agate.bind("hyper+shift+j", "move down")
            agate.bind("hyper+shift+k", "move up")
            agate.bind("hyper+shift+l", "move right")

            -- Layout control.
            agate.bind("hyper+b", function() agate.layout("h_tiles") end)      -- horizontal split
            agate.bind("hyper+v", function() agate.layout("v_tiles") end)      -- vertical split
            agate.bind("hyper+e", function() agate.layout("toggle") end)       -- swap split orientation
            agate.bind("hyper+s", function() agate.layout("accordion") end)    -- vertical stack (bottom peeks)
            agate.bind("hyper+shift+s", function() agate.layout("h_stack") end) -- horizontal stack

            -- Combine the focused window with a neighbour into a nested container, for mixed
            -- layouts (e.g. left/right tiled with the left slot holding two stacked windows).
            -- Second arg is the new container's layout (default "v_stack").
            agate.bind("hyper+g", function() agate.join("right") end)              -- stack with right neighbour
            agate.bind("hyper+shift+g", function() agate.join("right", "v_split") end) -- split with right neighbour

            -- Resize the focused tile.
            agate.bind("hyper+minus", function() agate.resize("left", 50) end)
            agate.bind("hyper+equal", function() agate.resize("right", 50) end)

            -- Instant space switching — uses SLSManagedDisplaySetCurrentSpace directly,
            -- not gesture emulation (which fails on macOS 26+).
            agate.bind("hyper+1", function() agate.space(1) end)
            agate.bind("hyper+2", function() agate.space(2) end)
            agate.bind("hyper+3", function() agate.space(3) end)
            agate.bind("hyper+4", function() agate.space(4) end)
            agate.bind("hyper+5", function() agate.space(5) end)
            agate.bind("hyper+6", function() agate.space(6) end)
            agate.bind("hyper+7", function() agate.space(7) end)
            agate.bind("hyper+8", function() agate.space(8) end)
            agate.bind("hyper+9", function() agate.space(9) end)

            -- Send the focused window to space N (does not follow focus).
            agate.bind("hyper+shift+1", function()
                agate.move_to_space(1)
                agate.space(1)
            end)
            agate.bind("hyper+shift+2", function()
                agate.move_to_space(2)
                agate.space(2)
            end)
            agate.bind("hyper+shift+3", function()
                agate.move_to_space(3)
                agate.space(3)
            end)
            agate.bind("hyper+shift+4", function()
                agate.move_to_space(4)
                agate.space(4)
            end)
            agate.bind("hyper+shift+5", function()
                agate.move_to_space(5)
                agate.space(5)
            end)
            agate.bind("hyper+shift+6", function()
                agate.move_to_space(6)
                agate.space(6)
            end)
            agate.bind("hyper+shift+7", function()
                agate.move_to_space(7)
                agate.space(7)
            end)
            agate.bind("hyper+shift+8", function()
                agate.move_to_space(8)
                agate.space(8)
            end)
            agate.bind("hyper+shift+9", function()
                agate.move_to_space(9)
                agate.space(9)
            end)

            -- Cycle through spaces.
            agate.bind("hyper+n", function() agate.space_next() end)
            agate.bind("hyper+p", function() agate.space_prev() end)

            -- Window assignment rules (yabai-style): when a matching window appears, it is
            -- sent to the given space and the view follows it there (`follow = false` to
            -- route it in the background instead). `app`/`title` are POSIX extended regexes
            -- (at least one required). The last matching rule wins.
            agate.rule({ app = "^Ghostty$", space = 2 })
            agate.rule({ app = "^Zen$", space = 1 })
            agate.rule({ app = "^Obsidian$", space = 3 })
            agate.rule({ app = "^Things$", space = 3 })
            agate.rule({ app = "^Spotify$", space = 5 })
            agate.rule({ app = "^Vesktop$", space = 4 })

            print("agate: development config loaded")
          '';
      };
    };
}
