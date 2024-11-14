{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = ../../../home/programs/plasma/wallpaper.jpg;
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";
    opacity.terminal = 0.9;
  };
}
