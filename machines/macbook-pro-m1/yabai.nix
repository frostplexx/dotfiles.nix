{config, ...}: {
  services = {
    jankyborders = {
      enable = true;
      style = "round";
      width = 3.0;
      hidpi = true;
      active_color = "0xff${config.accent_color}";
      inactive_color = "0xff7f849c";
    };

    yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        # Layout
        layout = "bsp";

        # Focus
        focus_follows_mouse = "off";
        mouse_follows_focus = "on";

        # Window placement
        window_placement = "second_child";
        auto_balance = "on";

        split_ratio = 0.5;
        window_animation_duration = 0.5;
        window_animation_easing = "ease_out_quint";

        # Opacity
        window_opacity = "on";
        window_shadow = "float";
        active_window_opacity = 1.0;
        normal_window_opacity = 0.8;
        window_opacity_duration = 0.2;

        # Gaps (matching aerospace config)
        top_padding = 0;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
      };

      extraConfig = ''
        sudo yabai --load-sa
        yabai -m signal --add event=dock_did_restart action="sudo yabai --load-sa && pkill -9 lazykeys && pkill -9 skhd"

        # Window rules (matching aerospace on-window-detected)

        # Floating Rules
        yabai -m rule --add app="^Zen Browser$" title="Picture-in-Picture" manage=off
        yabai -m rule --add app="^(LuLu|Calculator|Software Update|Dictionary|VLC|System Preferences|System Settings|zoom.us|Photo Booth|Archive Utility|Python|LibreOffice|App Store|Kitty|Alfred|Activity Monitor)$" manage=off
        yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
        yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
        yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off

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

      '';
    };
  };
}
