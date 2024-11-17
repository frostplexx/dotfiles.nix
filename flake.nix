# flake.nix
{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";
    nur.url = "github:nix-community/nur";
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    yuki = {
      url = "github:frostplexx/yuki/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # yuki.url = "git+file:///Users/daniel/Developer/yuki";
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord = {
      url = "github:kaylorben/nixcord";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # In your flake.nix, replace just the outputs section:
  outputs = {
    nixpkgs,
    home-manager,
    nix-darwin,
    flake-utils,
    ...
  } @ inputs: let
    # Set some global variables
    vars = {
      user = "daniel";
      location = "$HOME/.setup";
      terminal = "kitty";
      editor = "nvim";
    };
  in
    # First, generate the system-specific outputs (shells, formatter)
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        devShells = import ./shells {inherit pkgs;};
        formatter = pkgs.alejandra;
      }
    )
    // {
      # Your existing nixosConfigurations and darwinConfigurations stay the same
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit vars inputs;};
        modules = [
          ./nix/core.nix
          inputs.yuki.nixosModules.default
          ./hosts/nixos/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [inputs.nur.overlay];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit vars inputs;};
              users.${vars.user} = import ./home;
              sharedModules = [
                inputs.plasma-manager.homeManagerModules.plasma-manager
                inputs.nixcord.homeManagerModules.nixcord
              ];
            };
          }
        ];
      };

      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {inherit vars inputs;};
        modules = [
          ./nix/core.nix
          inputs.yuki.nixosModules.default
          inputs.stylix.darwinModules.stylix
          ./hosts/darwin/configuration.nix
          inputs.darwin-custom-icons.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.nixpkgs-firefox-darwin.overlay
              inputs.nur.overlay
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {inherit vars inputs;};
              users.${vars.user} = import ./home;
              sharedModules = [
                inputs.plasma-manager.homeManagerModules.plasma-manager
                inputs.nixcord.homeManagerModules.nixcord
              ];
            };
          }
        ];
      };
    };
}
