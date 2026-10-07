{self, ...}: {
  flake.homeManagerModules.skhd = {
    pkgs,
    lib,
    ...
  }: let
    wb = lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.windowbuddy;
  in {
    services.skhd = {
      enable = true;
      package = pkgs.skhd_zig;
      config = ''
        ctrl + alt + cmd - 1 : ${wb} space 4
        ctrl + alt + cmd - 2 : ${wb} space 5
        ctrl + alt + cmd - 3 : ${wb} space 6
        ctrl + alt + cmd - 4 : ${wb} space 2
        ctrl + alt + cmd - 5 : ${wb} space 3
        ctrl + alt + cmd - 6 : ${wb} space 1

        # move follows the window to its new space
        ctrl + alt + shift + cmd - 1 : ${wb} move 4
        ctrl + alt + shift + cmd - 2 : ${wb} move 5
        ctrl + alt + shift + cmd - 3 : ${wb} move 6
        ctrl + alt + shift + cmd - 4 : ${wb} move 2
        ctrl + alt + shift + cmd - 5 : ${wb} move 3
        ctrl + alt + shift + cmd - 6 : ${wb} move 1

        ctrl + alt + cmd - h : ${wb} focus left
        ctrl + alt + cmd - j : ${wb} focus down
        ctrl + alt + cmd - k : ${wb} focus up
        ctrl + alt + cmd - l : ${wb} focus right
      '';
    };
  };
}
