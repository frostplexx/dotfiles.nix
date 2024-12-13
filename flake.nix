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

    # Darwin-specific inputs
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Desktop environment and theming
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Application-specific inputs
    nur.url = "github:nix-community/nur";
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    yuki = {
      url = "github:frostplexx/yuki/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser.url = "git+file:///Users/daniel/Developer/zen-browser-flake";
  };

  outputs = inputs: let
    # Global variables used across configurations
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

  # some important changes
}
