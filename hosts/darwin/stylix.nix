{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = ../../../home/programs/plasma/wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    opacity.terminal = 0.8;
  };
}
