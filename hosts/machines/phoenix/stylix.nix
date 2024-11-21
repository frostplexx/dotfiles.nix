{pkgs, ...}: {
  stylix = {
    opacity.terminal = 0.5;
    targets = {
      # managed in ./system.nix
      plymouth = {
        enable = false;
        logoAnimated = false;
      };
    };
    cursor = {
      name = "phinger-cursors";
      package = pkgs.phinger-cursors;
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
        package = pkgs.nerdfonts.override {fonts = ["JetBrainsMono"];};
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
