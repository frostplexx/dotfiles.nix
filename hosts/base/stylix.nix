{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = true;
    image = ../../home/programs/plasma/wallpaper.png;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
  };
}
