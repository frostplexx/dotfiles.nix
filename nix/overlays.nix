
{ inputs }: let

  baseOverlays = {
    nixos = [
      inputs.nur.overlay
    ];
    darwin = [
      inputs.nur.overlay
      inputs.nixpkgs-firefox-darwin.overlay
    ];
  };
in
  baseOverlays
