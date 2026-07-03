_: {
  # Jinx module for Darwin
  flake.darwinModules.repodex = {pkgs, ...}: let
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
}
