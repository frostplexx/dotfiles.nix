{pkgs, ...}: {
  services = {
    # jankyborders = {
    #   enable = true;
    #   settings = {
    #     style = "round";
    #     width = 3.0;
    #     hidpi = true;
    #     active_color = "0xff${config.accent_color}";
    #     inactive_color = "0xff7f849c";
    #   };
    # };

    yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        # Layout
        layout = "bsp";

        # Focus
        focus_follows_mouse = "off";
        mouse_follows_focus = "off";

        # Window placement
        window_placement = "second_child";
        auto_balance = "off";

        # Opacity
        window_opacity = "off";
        window_shadow = "float";
        active_window_opacity = 1.0;
        normal_window_opacity = 0.9;

        # Gaps (matching aerospace config)
        top_padding = 0;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
      };

      extraConfig = ''
        # Window rules (matching aerospace on-window-detected)

        # Picture-in-Picture windows should float
        yabai -m rule --add app="^Zen Browser$" title="Picture-in-Picture" manage=off

        # Browser apps -> Space 1
        yabai -m rule --add app="^Firefox$" space=1
        yabai -m rule --add app="^Zen Browser$" space=1

        # Development apps -> Space 2
        yabai -m rule --add app="^IntelliJ IDEA$" space=2
        yabai -m rule --add app="^WezTerm$" space=2
        yabai -m rule --add app="^Ghostty$" space=2
        yabai -m rule --add app="^Termius$" space=2
        yabai -m rule --add app="^kitty$" space=2
        yabai -m rule --add app="^kitty$" title="kittyfloat" manage=off

        # Productivity apps -> Space 3
        yabai -m rule --add app="^GoodNotes$" space=3
        yabai -m rule --add app="^Obsidian$" space=3
        yabai -m rule --add app="^Things$" space=3

        # Communication apps -> Space 4
        yabai -m rule --add app="^Vesktop$" space=4
        yabai -m rule --add app="^zoom.us$" space=4
        yabai -m rule --add app="^Discord$" space=4
        yabai -m rule --add app="^Mail$" space=4

        # Music -> Space 5
        yabai -m rule --add app="^Spotify$" space=5
        yabai -m rule --add app="^Music$" space=5
        yabai -m rule --add title="MiniPlayer" manage=off

        # Floating apps
        yabai -m rule --add app="^Finder$" manage=off
        yabai -m rule --add app="^1Password$" manage=off
        yabai -m rule --add app="^CleanShot X$" manage=off
        yabai -m rule --add app="^Keka$" manage=off
        yabai -m rule --add app="^Simulator$" manage=off
        yabai -m rule --add app="^Google Chrome$" manage=off

        # Signals for sketchybar integration
        # yabai -m signal --add event=space_changed action="${pkgs.sketchybar}/bin/sketchybar --trigger aerospace_workspace_changed FOCUSED_WORKSPACE=\$YABAI_SPACE_ID"
        # yabai -m signal --add event=window_focused action="${pkgs.sketchybar}/bin/sketchybar --trigger space_windows_change"
        # yabai -m signal --add event=window_focused action="${pkgs.sketchybar}/bin/sketchybar --trigger front_app_switched"
        # yabai -m signal --add event=application_front_switched action="${pkgs.sketchybar}/bin/sketchybar --trigger front_app_switched"

        # Reload sketchybar on startup
        # ${pkgs.sketchybar}/bin/sketchybar --reload
        sudo yabai --load-sa
      '';
    };
  };
}
