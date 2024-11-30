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
      name = "Phinger Cursors (dark)";
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
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };
      sansSerif = {
        package = pkgs.noto-fonts;
        name = "Noto Sans";
      };
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };
      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
