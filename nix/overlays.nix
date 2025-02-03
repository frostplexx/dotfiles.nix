{inputs}: let
  baseOverlays = {
    nixos = [
      inputs.nur.overlays.default
      inputs.niri.overlays.niri
    ];
    darwin = [
      inputs.nur.overlays.default
      inputs.nixpkgs-firefox-darwin.overlay
    ];
  };
in
  baseOverlays
