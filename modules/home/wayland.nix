_: {
  flake.modules.homeManager.hyprland =
    { inputs, pkgs, ... }:
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage =
          inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        settings = {
          # Hyprland configuration options
          # For example:
          # theme = "catppuccin";
          # autoupdate = false;
        };
      };
    };
}
