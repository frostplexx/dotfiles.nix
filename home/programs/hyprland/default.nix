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
    rofi = {
      enable = true;
    };
    wlogout = {
      enable = true;
    };
    hyprlock = {
      enable = true;
    };
    waybar = {
      enable = true;
    };
    anyrun = {
      enable = true;
      config = {
        x = {fraction = 0.5;};
        y = {fraction = 0.3;};
        width = {fraction = 0.3;};
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = false;
        showResultsImmediately = false;
        maxEntries = null;
      };
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
