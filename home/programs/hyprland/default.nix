{pkgs, ...}: {
  xdg.configFile = {
    # Copy the filtered nvim configuration directory
    "hypr" = {
      source = ./hypr;
      recursive = true;
    };
    "swaync" = {
      source = ./swaync;
      recursive = true;
    };
    "waybar" = {
      source = ./waybar;
      recursive = true;
    };
    "wlogout" = {
      source = ./wlogout;
      recursive = true;
    };
  };

  programs = {
    wlogout = {
      enable = true;
    };
    hyprlock = {
      enable = true;
    };
    waybar = {
      enable = true;
    };
    wofi = {
      enable = true;
      settings = {
        width = "50%";
        height = "40%";
        show = "drun";
        insensitive = true;

        key_up = "Ctrl+k";
        key_down = "Ctrl+j";
        key_left = "Ctrl+h";
        key_right = "Ctrl+l";
      };
      # style = builtins.readFile ./wofi/style.css;
    };
  };

  services = {
    swaync = {
      enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    # Whether to enable Hyprland wayland compositor
    enable = true;
    # The hyprland package to use
    package = pkgs.hyprland;
    # Whether to enable XWayland
    xwayland.enable = true;

    # Optional
    # Whether to enable hyprland-session.target on hyprland startup
    systemd.enable = true;
  };
}
