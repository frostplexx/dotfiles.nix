_: {
  flake.modules.homeManager.hyprland =
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    let
      accent_color = "cba6f7";
    in
    {
      xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
        # Copy the filtered nvim configuration directory
        "hypr" = {
          source = ./hyprland/hypr;
          recursive = true;
        };
        "rofi" = {
          source = ./hyprland/rofi;
          recursive = true;
        };
        # "swaync" = {
        #   source = ./hyprland/swaync;
        #   recursive = true;
        # };
        "waybar" = {
          source = ./hyprland/waybar;
          recursive = true;
        };
        "wlogout" = {
          source = ./hyprland/swaync;
          recursive = true;
        };
      };

      programs = lib.mkIf pkgs.stdenv.isLinux {
        rofi = {
          enable = true;
        };
        wlogout = {
          enable = true;
        };

        waybar.enable = true;
      };

      # services.swaync = lib.mkIf pkgs.stdenv.isLinux {
      #   enable = true;
      # };

      wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {

        # Whether to enable Hyprland wayland compositor
        enable = true;
        # The hyprland package to use
        package = pkgs.hyprland;
        # Whether to enable XWayland
        xwayland.enable = true;

        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

        # Optional
        # Whether to enable hyprland-session.target on hyprland startup
        systemd.enable = true;
      };

    };
}
