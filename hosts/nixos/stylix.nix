{ pkgs, ... }:

{
  stylix = {
    enable = true;
    image = ../../home/programs/plasma/wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    opacity.terminal = 0.5;
    targets = {
      plymouth = {
        enable = true;
        logoAnimated = false;
      };
    };
    cursor = {
      name = "Vimix-Cursors";
      package = pkgs.vimix-cursor-theme;
      size = 28;
    };

    fonts = {
      sizes = {
        applications = 11;
        terminal = 11;
        desktop = 11;
        popups = 11;
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; };
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
