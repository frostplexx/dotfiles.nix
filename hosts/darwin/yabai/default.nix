{
  services.yabai = {
    enable = true;
    # enableScriptingAddition = true;
    config = {
      layout = "bsp";
      auto_balance = "on";

      mouse_modifier = "fn";
      # set modifier + right-click drag to resize window (default: resize)
      mouse_action2 = "resize";
      # set modifier + left-click drag to resize window (default: move)
      mouse_action1 = "move";

      # gaps
      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };
    extraConfig = ''

      # Window appearance
      yabai -m config window_shadow float
      yabai -m config window_opacity on

      yabai -m space 1 --label web
      yabai -m space 2 --label dev
      yabai -m space 3 --label docs
      yabai -m space 4 --label comms
      yabai -m space 5 --label media

      # Unmanaged apps
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^1Password$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^Archive Utility$" manage=off


      # Space assignments with labels and proper management
      yabai -m rule --add app="^Arc$" space=1 manage=on
      yabai -m rule --add app="^Firefox$" space=1 manage=on

      yabai -m rule --add app="^kitty$" space=2 manage=on
      yabai -m rule --add app="^Alacritty$" space=2 manage=on
      yabai -m rule --add app="^Terminal$" space=2 manage=on
      yabai -m rule --add app="^XCode$" space=2 manage=on


      yabai -m rule --add app="^Obsidian$" space=3 manage=on
      yabai -m rule --add app="^Goodnotes$" space=3 manage=on

      yabai -m rule --add app="^Messages$" space=4 manage=on
      yabai -m rule --add app="^WhatsApp$" space=4 manage=on
      yabai -m rule --add app="^Vesktop$" space=4 manage=on
      yabai -m rule --add app="^Discord$" space=4 manage=on
      yabai -m rule --add app="^zoom.us$" space=4 manage=on

      yabai -m rule --add app="^Spotify$" space=5 manage=on
      yabai -m rule --add title="^Spotify Premium$" space=5 manage=on
      yabai -m rule --add app="^Music$" space=5 manage=on


      # Handle window creation for floating windows
      yabai -m signal --add event=window_created action='bash -c "
          window_id=$YABAI_WINDOW_ID
          if yabai -m query --windows --window $window_id | jq -er \".\"can-resize\" or .\"is-floating\"\" > /dev/null; then
              yabai -m window $window_id --toggle float --layer above --grid 4:4:1:1:2:2
          fi
      "'
    '';
  };
}
