{ pkgs, lib, ... }:
{
  xdg.configFile = lib.mkIf pkgs.stdenv.isDarwin {
    "aerospace/aerospace.toml" = {
      source = ./aerospace.toml;
      recursive = true;
    };
  };
}
