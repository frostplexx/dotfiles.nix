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
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";

    # Darwin-specific inputs
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

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

    # Development tools
    yuki = {
      url = "github:frostplexx/yuki/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs: let
    # Global variables used across configurations
    vars = {
      user = "daniel";
      location = "$HOME/.setup";
      terminal = "kitty";
      editor = "nvim";
    };

    # Import our utils function
    utils = import ./nix/utils.nix {
      inherit inputs vars;
    };
  in
    utils.lib.mkFlake {
      inherit inputs;
      imports = [
        ./hosts     # System configurations
      ];
    };
}
