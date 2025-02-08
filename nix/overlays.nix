{inputs}: let
  baseOverlays = {
    nixos = [
      inputs.nur.overlays.default
      inputs.niri.overlays.niri
      inputs.neovim-nightly-overlay.overlays.default
    ];
    darwin = [
      inputs.nur.overlays.default
      inputs.nixpkgs-firefox-darwin.overlay
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };
in
  baseOverlays
