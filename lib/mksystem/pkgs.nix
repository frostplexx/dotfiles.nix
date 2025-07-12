{ inputs, system, overlays }:
let
  nixpkgsConfig = {
    allowUnfree = true;
    allowUnsupportedSystem = false;
    allowBroken = true;
    allowInsecure = true;
  };
  pkgs = import inputs.nixpkgs {
    inherit system overlays;
    config = nixpkgsConfig;
  };
in
{
  inherit pkgs nixpkgsConfig;
}
