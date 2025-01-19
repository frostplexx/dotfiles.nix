{config, pkgs, ... }:
{


  xdg.configFile = {
    # Copy the filtered nvim configuration directory
    "hypr" = {
      source = ./hypr;
      recursive = true;
    };
    "rofi" = {
      source = ./rofi;
      recursive = true;
    };
    "swaync" = {
      source = ./swaync;
      recursive = true;
    };
    "waybar" = {
      source = ./swaync;
      recursive = true;
    };
    "wlogout" = {
      source = ./swaync;
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
  };

  services.swaync = {
    enable = true;
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

