{ pkgs, lib, ... }:
{
  xdg.configFile = lib.mkIf pkgs.stdenv.isDarwin {
    "skhd/skhdrc" = {
      source = ./skhd.conf;
      recursive = true;
    };
  };
}
