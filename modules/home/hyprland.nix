_: {
  flake.modules.homeManager.hyprland = {
    inputs,
    pkgs,
    lib,
    ...
  }: {
    wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      # Whether to enable XWayland
      xwayland.enable = true;

      # Optional
      # Whether to enable hyprland-session.target on hyprland startup
      systemd.enable = true;
      settings = {
        "$mod" = "SUPER";

        monitor = "DP-1, 2560x1080@144, 0x0, 1";

        bind = [
          # keybindings
          "$mod, Return, exec, kitty"
          "$mod, d, exec, rofi -show drun"
        ];

        bindm = [
          # mouse movements
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
          "$mod ALT, mouse:272, resizewindow"
        ];
      };
    };
  };
}
