{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";
  nixConfig.commit-lockfile-summary = "flake: bump inputs";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    lix = {
      url = "https://git.lix.systems/lix-project/lix/archive/main.tar.gz";
      flake = false;
    };

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix.follows = "lix";
    };

    # Darwin-specific inputs
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application-specific inputs
    nur.url = "github:nix-community/nur";
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    # Desktop environments
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs = inputs: let
    vars = {
      user = "daniel";
    };

    utils = import ./nix/utils.nix {
      inherit inputs vars;
    };
  in
    utils.lib.mkFlake {
      inherit inputs;
      imports = [
        ./hosts
      ];
    };
}
