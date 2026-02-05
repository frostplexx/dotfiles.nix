{...}: {
    flake.modules.homeManager.skhd = {
        pkgs,
        lib,
        ...
    }: {
        services.skhd = lib.mkIf pkgs.stdenv.isDarwin {
            enable = true;
            config = ''
                # Layout modes
                ctrl + alt + cmd - t : yabai -m space --layout bsp
                ctrl + alt + cmd - s : yabai -m space --layout stack

                # Fullscreen
                ctrl + alt + cmd - space : yabai -m window --toggle zoom-fullscreen

                # Toggle floating
                ctrl + alt + cmd - f : yabai -m window --toggle float

                # Minimize
                cmd - m : yabai -m window --minimize

                # Launch applications
                ctrl + alt + cmd - return : open -a kitty
                ctrl + alt + cmd - m : open -a Music
                ctrl + alt + cmd - b : open -a Zen
                ctrl + alt + cmd + shift - return : open -a kitty

                # Focus windows (hjkl)
                ctrl + alt + cmd - h : yabai -m window --focus west
                ctrl + alt + cmd - j : yabai -m window --focus south || yabai -m window --focus stack.prev
                ctrl + alt + cmd - k : yabai -m window --focus north || yabai -m window --focus stack.next
                ctrl + alt + cmd - l : yabai -m window --focus east

                # Switch to workspace
                ctrl + alt + cmd - 1 : yabai -m space --focus 1
                ctrl + alt + cmd - 2 : yabai -m space --focus 2
                ctrl + alt + cmd - 3 : yabai -m space --focus 3
                ctrl + alt + cmd - 4 : yabai -m space --focus 4
                ctrl + alt + cmd - 5 : yabai -m space --focus 5
                ctrl + alt + cmd - 6 : yabai -m space --focus 6

                # Move window to workspace and follow
                ctrl + alt + shift + cmd - 1 : yabai -m window --space 1 && yabai -m space --focus 1
                ctrl + alt + shift + cmd - 2 : yabai -m window --space 2 && yabai -m space --focus 2
                ctrl + alt + shift + cmd - 3 : yabai -m window --space 3 && yabai -m space --focus 3
                ctrl + alt + shift + cmd - 4 : yabai -m window --space 4 && yabai -m space --focus 4
                ctrl + alt + shift + cmd - 5 : yabai -m window --space 5 && yabai -m space --focus 5
                ctrl + alt + shift + cmd - 6 : yabai -m window --space 6 && yabai -m space --focus 6

                # Move windows (swap)
                ctrl + alt + shift + cmd - h : yabai -m window --swap west  || yabai -m config layout bsp && yabai -m window --warp west
                ctrl + alt + shift + cmd - j : yabai -m window --swap south || yabai -m config layout bsp && yabai -m window --warp south
                ctrl + alt + shift + cmd - k : yabai -m window --swap north || yabai -m config layout bsp && yabai -m window --warp north
                ctrl + alt + shift + cmd - l : yabai -m window --swap east  || yabai -m config layout bsp && yabai -m window --warp east

                # Stack windows (similar to aerospace join-with)
                alt + shift - h : yabai -m window --stack west  || yabai -m window --warp west
                alt + shift - j : yabai -m window --stack south || yabai -m window --warp south
                alt + shift - k : yabai -m window --stack north || yabai -m window --warp north
                alt + shift - l : yabai -m window --stack east  || yabai -m window --warp east

                # Focus back and forth
                alt - tab : yabai -m window --focus recent

                # Move workspace to next display
                alt + shift - tab : yabai -m space --display next || yabai -m space --display first

                # Reload yabai
                ctrl + alt + cmd - r : launchctl kickstart -k "gui/$UID/org.nixos.yabai"
            '';
        };
    };
}
