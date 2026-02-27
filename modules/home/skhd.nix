_: {
  flake.modules.homeManager.skhd = {
    pkgs,
    lib,
    ...
  }: let
    accent_color = "cba6f7";
  in {
    services.skhd = lib.mkIf pkgs.stdenv.isDarwin {
      enable = true;
      config = ''

         # Modes
        :: launch @
        :: tiling @ : borders active_color=0xff8aadf4
        :: default : borders active_color=0xff${accent_color}
        :: resize : borders active_color=0xffed8796
        :: music : borders active_color=0xffa6e3a1

        ctrl + alt + cmd - d ; launch
        ctrl + alt + cmd - t ; tiling
        ctrl + alt + cmd - r ; resize

        # Launch apps
        launch < d : open -a Discord & skhd -k 'escape'
        launch < m : open -a TIDAL & skhd -k 'escape'
        launch < t : open -a kitty & skhd -k 'escape'
        launch < b : open -a Zen & skhd -k 'escape'


        # Volume control for spotify
        # music < ] : osascript -e 'tell application "Spotify" set currentvol to get sound volume set sound volume to currentvol + 10 end tell' & skhd -k 'escape'
        # music < ] : osascript -e ' tell application "Spotify" set currentvol to get sound volume set sound volume to currentvol - 10 end tell' & skhd -k 'escape'



        # Layout modes
        tiling < t : yabai -m space --layout bsp  & skhd -k 'escape'
        tiling < s : yabai -m space --layout stack & skhd -k 'escape'
        tiling < f : yabai -m window --toggle float & skhd -k 'escape'
        tiling < cmd - f : yabai -m space --layout float & skhd -k 'escape'
        # tiling < z : yabai -m window --toggle float & yabai -m window --resize abs:960:540 & yabai -m window --move abs:960:540 & skhd -k 'escape'

        # Resize modes
        resize < h : yabai -m window --resize left:-20:0
        resize < j : yabai -m window --resize bottom:0:20
        resize < k : yabai -m window --resize top:0:-20
        resize < l : yabai -m window --resize right:20:0


        # Return to default mode
        launch < escape ; default
        tiling < escape ; default
        resize < escape ; default
        music < escape ; default


        # Fullscreen
        ctrl + alt + cmd - space : yabai -m window --toggle zoom-fullscreen


        # Minimize
        cmd - m : yabai -m window --minimize


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
        ctrl + alt + cmd - 6 : yabai -m space --focus 7
        ctrl + alt + cmd - 6 : yabai -m space --focus 8
        ctrl + alt + cmd - 6 : yabai -m space --focus 9
        ctrl + alt + cmd - 6 : yabai -m space --focus 0

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
      '';
    };
  };
}
