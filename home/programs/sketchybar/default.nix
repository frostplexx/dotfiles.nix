{
  pkgs,
  lib,
  ...
}: {
  xdg.configFile = lib.mkIf pkgs.stdenv.isDarwin {
    "sketchybar" = {
      source = ./config;
      recursive = true;
    };
  };
}
