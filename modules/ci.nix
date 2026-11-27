{
  self,
  lib,
  ...
}: let
  # nix-fast-build needs an attribute set of derivations, keyed by system.
  # One entry per host, so a Linux runner builds only the Linux entries and a
  # macOS runner only the Darwin ones.
  nixos = lib.mapAttrs (_: c: c.config.system.build.toplevel) self.nixosConfigurations;
  darwin = lib.mapAttrs (_: c: c.system) self.darwinConfigurations;
in {
  flake.ciTargets = {
    x86_64-linux = nixos;
    aarch64-darwin = darwin;
  };
}
