# flake.nix
{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";

  # Configure Nix behavior
  nixConfig = {
    # Enable the official cache to avoid unnecessary builds
    substituters = [
      "https://cache.nixos.org"
    ];

    # Enable flakes and new nix command
    experimental-features = [ "nix-command" "flakes" ];

    # Additional binary caches for community packages
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    # Trust keys for the additional caches
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Define external dependencies
  inputs = {
    # Core package source
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home directory management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as the main system
    };

    # macOS system configuration
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Additional features and tools
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";
    nur.url = "github:nix-community/nur"; # Nix User Repository

    # KDE Plasma configuration management
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Firefox for Darwin systems
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    # Package manager
    yuki.url = "github:frostplexx/yuki/dev";

    # System theming
    stylix.url = "github:danth/stylix";

    # Utilities for working with flakes
    flake-utils.url = "github:numtide/flake-utils";
  };

  # Define the outputs for this flake
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
      # Global variables used throughout the configuration
      vars = {
        user = "daniel";
        location = "$HOME/.setup";
        terminal = "kitty";
        editor = "nvim";
      };

      # Helper function to create a consistent package set for a given system
      # This ensures all packages are built with the same configuration
      mkPkgs = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Allow proprietary software
      };

      # Generate system-specific outputs (shells, formatters, etc.)
      # This uses flake-utils to automatically handle different systems
      systemOutputs = flake-utils.lib.eachDefaultSystem (system:
        let
          # Get the appropriate package set for this system
          pkgs = mkPkgs system;
        in
        {
          # Development shells are dynamically loaded from the shells directory
          # The implementation is in shells/default.nix
          devShells = import ./shells { inherit pkgs; };

          # Provide a formatter for .nix files on each system
          formatter = pkgs.nixpkgs-fmt;
        });

    in
    # Merge system-specific outputs with NixOS and Darwin configurations
    systemOutputs // {
      # System auto-upgrade configuration
      system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        flags = [
          "--update-input"
          "nixpkgs"
          "-L" # Show more detailed logs
        ];
        dates = "9:00";
        randomizedDelaySec = "45min";
      };

      # NixOS system configuration
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit vars inputs; }; # Pass variables to modules
        modules = [
          # Load various system modules
          inputs.yuki.nixosModules.default
          ./hosts/nixos/configuration.nix
          inputs.stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager
          {
            # Enable NUR overlay for additional packages
            nixpkgs.overlays = [ inputs.nur.overlay ];

            # Configure home-manager for the user
            home-manager = {
              useGlobalPkgs = true; # Use the system's package set
              useUserPackages = true; # Install user packages to /etc/profiles
              extraSpecialArgs = { inherit vars inputs; };
              users.${vars.user} = import ./home;
              sharedModules = [
                plasma-manager.homeManagerModules.plasma-manager
              ];
            };
          }
        ];
      };

      # macOS (Darwin) system configuration
      darwinConfigurations.darwin = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit inputs vars; };
        modules = [
          # Load system modules
          yuki.nixosModules.default
          inputs.stylix.darwinModules.stylix
          ./hosts/darwin/configuration.nix
          darwin-custom-icons.darwinModules.default
          home-manager.darwinModules.home-manager
          {
            # Enable overlays for Darwin-specific packages
            nixpkgs.overlays = [
              inputs.nixpkgs-firefox-darwin.overlay
              inputs.nur.overlay
            ];

            # Configure home-manager for the user
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
