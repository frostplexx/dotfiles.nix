{pkgs, ...}: {
  services.yabai = {
    enable =
      if pkgs.stdenv.isDarwin
      then true
      else false;
    config = {
      layout = "bsp";
      auto_balance = "on";

      mouse_modifier = "fn";
      # set modifier + right-click drag to resize window (default: resize)
      mouse_action2 = "resize";
      # set modifier + left-click drag to resize window (default: move)
      mouse_action1 = "move";

      # gaps
      top_padding = 5;
      bottom_padding = 5;
      left_padding = 5;
      right_padding = 5;
      window_gap = 5;
    };
    extraConfig = ''

      # Restart yabai scripting addition
      yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa"
      sudo yabai --load-sa

      # Window appearance
      yabai -m config window_shadow float
      yabai -m config window_opacity on

      # Unmanaged apps
      yabai -m rule --add app="^System Settings$" manage=off
      yabai -m rule --add app="^1Password$" manage=off
      yabai -m rule --add app="^Finder$" manage=off
      yabai -m rule --add app="^Raycast$" manage=off
      yabai -m rule --add app="^Archive Utility$" manage=off


      # Space assignments with labels and proper management
      yabai -m rule --add app="^Arc$" space=1 manage=on label="browser"
      yabai -m rule --add app="^Firefox$" space=1 manage=on label="browser"

      yabai -m rule --add app="^kitty$" space=2 manage=on label="terminal"
      yabai -m rule --add app="^Alacritty$" space=2 manage=on label="terminal"
      yabai -m rule --add app="^Terminal$" space=2 manage=on label="terminal"
      yabai -m rule --add app="^XCode$" space=2 manage=on label="dev"

      yabai -m rule --add app="^Messages$" space=3 manage=on label="communication"
      yabai -m rule --add app="^WhatsApp$" space=3 manage=on label="communication"
      yabai -m rule --add app="^Vesktop$" space=3 manage=on label="communication"
      yabai -m rule --add app="^Discord$" space=3 manage=on label="communication"
      yabai -m rule --add app="^zoom.us$" space=3 manage=on label="communication"

      yabai -m rule --add app="^Spotify$" space=4 manage=on label="media"
      yabai -m rule --add title="^Spotify Premium$" space=4 manage=on label="media"
      yabai -m rule --add app="^Music$" space=4 manage=on label="media"

      yabai -m rule --add app="^Obsidian$" space=5 manage=on label="notes"
      yabai -m rule --add app="^Goodnotes$" space=5 manage=on label="notes"

      # Handle window creation for floating windows
      yabai -m signal --add event=window_created action='bash -c "
          window_id=$YABAI_WINDOW_ID
          if yabai -m query --windows --window $window_id | jq -er \".\"can-resize\" or .\"is-floating\"\" > /dev/null; then
              yabai -m window $window_id --toggle float --layer above --grid 4:4:1:1:2:2
          fi
      "'

      # Start borders
      borders active_color=0xff8aadf4 inactive_color=0x00494d64 width=4.0 &
    '';
  };
}
