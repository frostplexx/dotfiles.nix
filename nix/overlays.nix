{inputs}: let
  baseOverlays = {
    nixos = [
      inputs.nur.overlays.default
    ];
    darwin = [
      inputs.nur.overlays.default
      inputs.nixpkgs-firefox-darwin.overlay
    ];
  };
in
  baseOverlays
