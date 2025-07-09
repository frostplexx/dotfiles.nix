{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "jinx" ''
      exec ${pkgs.just}/bin/just --justfile "$HOME/dotfiles.nix/scripts/jinx/justfile" "$@"
    '')
  ];
}
