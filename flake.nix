# flake.nix
{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
    ];
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
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
    yuki.url = "github:frostplexx/yuki/dev";
    stylix.url = "github:danth/stylix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs @ { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , darwin-custom-icons
    , plasma-manager
    , yuki
    , flake-utils
    , ...
  }:
    let
      # Set some global variables
      vars = {
        user = "daniel";
        location = "$HOME/dotfiles.nix;
        terminal = "kitty";
        editor = "nvim";
      };

      # Helper function to create package sets
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # List of supported systems
      supportedSystems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      # Generate per-system outputs
      systemOutputs = flake-utils.lib.eachSystem supportedSystems (system:
        let
          pkgs = mkPkgs system;
        in
        {
          # Expose development shells
          devShells = import ./shells { inherit pkgs; };

          # Per-system formatter
          formatter = pkgs.nixpkgs-fmt;
        }
      );

      # Combine system-specific outputs with configurations
    in systemOutputs // {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit vars inputs; };
        modules = [
          inputs.yuki.nixosModules.default
          ./hosts/nixos/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [ inputs.nur.overlay ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit vars inputs; };
              users.${vars.user} = import ./home;
              sharedModules = [
                plasma-manager.homeManagerModules.plasma-manager
              ];
            };
          }
        ];
      };

      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs vars; };
        modules = [
          yuki.nixosModules.default
          inputs.stylix.darwinModules.stylix
          ./hosts/darwin/configuration.nix
          darwin-custom-icons.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.nixpkgs-firefox-darwin.overlay
              inputs.nur.overlay
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = { inherit vars inputs; };
              sharedModules = [
                plasma-manager.homeManagerModules.plasma-manager
              ];
              users.${vars.user} = import ./home;
            };
          }
        ];
      };
    };
}
