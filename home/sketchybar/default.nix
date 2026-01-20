{pkgs, ...}: {
    programs.sketchybar = {
        enable = true;
        extraPackages = with pkgs; [
            lua
            jq
            sbarlua
            aerospace
            nowplaying-cli
            switchaudio-osx
            bash
            gnumake
        ];
        service = {
            enable = true;
            errorLogFile = /tmp/sketchyerr;
            outLogFile = /tmp/sketchylog;
        };
        luaPackage = pkgs.lua5_4;
        sbarLuaPackage = pkgs.sbarlua;
    };
    home.file = {
        ".config/sketchybar" = {
            source = ./config/.;
            recursive = true;
            onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
        };
        ".local/share/sketchybar_lua/sketchybar.so" = {
            source = "${pkgs.sbarlua}/lib/lua/5.4/sketchybar.so";
            onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
        };
        ".config/sketchybar/sketchybarrc" = {
            text = ''
                #!/usr/bin/env ${pkgs.lua54Packages.lua}/bin/lua
                -- This is only needed once to install the sketchybar module
                -- (or for an update of the module)

                -- Add the sketchybar module to the package cpath (the module could be
                -- installed into the default search path then this would not be needed)
                package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

                -- Require the sketchybar module
                sbar = require("sketchybar")

                -- Bundle the entire initial configuration into a single message to sketchybar
                -- This improves startup times drastically, try removing both the begin and end
                -- config calls to see the difference -- yeah..
                sbar.begin_config()
                require("init")
                sbar.hotload(true)
                sbar.end_config()

                -- Run the event loop of the sketchybar module (without this there will be no
                -- callback functions executed in the lua module)
                sbar.event_loop()
            '';
            executable = true;
            onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
        };

        ".config/sketchybar/theme.lua" = {
            text = ''
                return {
                  crust = 0xff1a1b26,
                  mantle = 0xff414868,
                  base = 0xff24283b,
                  text = 0xffc0caf5,
                  muted = 0xff9aa5ce,
                  red = 0xfff7768e,
                  orange = 0xffff9e64,
                  yellow = 0xffe0af68,
                  green = 0xff9ece6a,
                  cyan = 0xff2ac3de,
                  blue = 0xff7aa2f7,
                  purple = 0xffbb9af7,
                }
            '';
        };
    };
}
