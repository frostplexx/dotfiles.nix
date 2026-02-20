_: {
  flake.modules.homeManager.hyprland =
    { inputs, pkgs, ... }:
    {
      wayland.windowManager.hyprland = {
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
          # Hyprland configuration options
          # For example:
          # theme = "catppuccin";
          # autoupdate = false;
        };
      };
    };
}
