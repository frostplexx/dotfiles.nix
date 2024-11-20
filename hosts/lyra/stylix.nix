{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../../home/programs/plasma/wallpaper.jpg;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    opacity.terminal = 0.9;
  };
}
