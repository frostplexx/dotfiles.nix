_: let
  # Repodex: project/repo manager (wraps ./repodex/justfile), for both
  # nix-darwin and NixOS.
  module = {pkgs, ...}: let
    repodex = pkgs.writeShellApplication {
      name = "repodex";
      runtimeInputs = [pkgs.just];
      text = ''
        exec just --justfile "$HOME/dotfiles.nix/modules/apps/repodex/justfile" "$@"
      '';
    };
  in {
    environment.systemPackages = [repodex];
  };
in {
  flake.darwinModules.repodex = module;
  flake.nixOSModules.repodex = module;
}
