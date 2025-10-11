_: {
  services = {
    yabai = {
      enable = true;
      enableScriptingAddition = true;
      config = {
        layout = "bsp";
        focus_follows_mouse = "autoraise";
        mouse_follows_focus = "off";
        window_placement = "second_child";
        window_opacity = "off";
        auto_balance  = "on";
        window_shadow = "float";
        active_window_opacity = 1.0;
        normal_window_opacity = 0.9;
        top_padding = 5;
        bottom_padding = 5;
        left_padding = 5;
        right_padding = 5;
        window_gap = 5;
      };
    };
    skhd = {
      enable = true;
      skhdConfig = ''
        ctrl + cmd + alt - 1: yabai -m space --focus 1
        ctrl + cmd + alt - 2: yabai -m space --focus 2
        ctrl + cmd + alt - 3: yabai -m space --focus 3
      '';
    };
  };
}
