{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";
  nixConfig = {
    # Enable nix cache so it doesnt need to build everything from source
    substituters = [
      "https://cache.nixos.org"
    ];
    # Add these to ensure proper updating
    experimental-features = [ "nix-command" "flakes" ];
    # Enable content-addressed derivations
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    # Main nix packages repository
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Manage user configuration with Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Manage system configuration on macOS with Nix Darwin
    nix-darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Custom icons for Nix Darwin
    darwin-custom-icons.url = "github:ryanccn/nix-darwin-custom-icons";
    # Community packages; used for Firefox extensions
    nur.url = "github:nix-community/nur";
    # Plasma Manager
    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixpkgs-firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";
    # Nix meta package manager (using dev branch)
    # yuki.url = "path:/Users/daniel/Developer/yuki";  # Use absolute path
    yuki.url = "github:frostplexx/yuki/dev"; # Use absolute path
    # Themeing for NixOS
    stylix.url = "github:danth/stylix";
  };
  outputs =
    inputs @ { self
    , nixpkgs
    , nix-darwin
    , home-manager
    , darwin-custom-icons
    , plasma-manager
    , yuki
    , nix
    , ...
    }:
    let

      # Set some global variables
      vars = {
        user = "daniel";
        location = "$HOME/.setup";
        terminal = "kitty";
        editor = "nvim";
      };
    in
    {
      # Enable auto-upgrades for the system
      # IDK if this is the right place
      system.autoUpgrade = {
        enable = true;
        flake = inputs.self.outPath;
        flags = [
          "--update-input"
          "nixpkgs"
          "-L"
        ];
        dates = "9:00";
        randomizedDelaySec = "45min";
      };


      # copnfiguration for nixos
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
              sharedModules =
                [
                  plasma-manager.homeManagerModules.plasma-manager
                ];
            };
          }
        ];
      };

      # configuration for macos
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
              sharedModules =
                [
                  plasma-manager.homeManagerModules.plasma-manager
                ];
              users.${vars.user} = import ./home;
            };
          }
        ];
      };


      # Formatter for nix files
      # only works on linux, TODO: make it work on darwin
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
