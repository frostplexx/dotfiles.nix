{
    description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Lix is a modern, delicious implementation of the Nix package manager
        lix-module = {
            url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        # Disko for configuring disk layouts
        # disko = {
        #   url = "github:nix-community/disko";
        #   inputs = {
        #     nixpkgs = {
        #       follows = "nixpkgs";
        #     };
        #   };
        # };

        # Darwin-specific inputs
        darwin = {
            url = "github:lnl7/nix-darwin/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        _1password-shell-plugins.url = "github:1Password/shell-plugins";

        # Declaratively manage homebrew
        nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
        # Homebrew Taps
        homebrew-core = {
            url = "github:homebrew/homebrew-core";
            flake = false;
        };
        homebrew-cask = {
            url = "github:homebrew/homebrew-cask";
            flake = false;
        };
        homebrew-nikitabobko = {
            url = "github:nikitabobko/homebrew-tap";
            flake = false;
        };

        # Needed for firefox addons
        nixcord = {
            url = "github:kaylorben/nixcord";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

        nixkit = {
            url = "github:frostplexx/nixkit";
            # or for local development:
            # url = "path:/Users/daniel/Developer/nixkit";
        };
    };

    outputs = {nixpkgs, ...} @ inputs: let
        overlays = [
            inputs.neovim-nightly-overlay.overlays.default
        ];

        mkSystem = import ./lib/mksystem.nix {
            inherit overlays nixpkgs inputs;
        };
    in {
        #TODO: implement: devShells = import ../shells;

        nixosConfigurations.pc-nixos = mkSystem "pc-nixos" {
            system = "x86_64-linux";
            user = "daniel";
            # Home manager modules you want to include as defined in ./home
            hm-modules = [
                "git"
                "gnome"
                "kitty"
                "neovim"
                "nixcord"
                "shell"
                "ssh"
                "zed"
            ];
        };

        darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
            system = "aarch64-darwin";
            user = "daniel";
            # Home manager modules you want to include as defined in ./home
            hm-modules = [
                "ghostty"
                "git"
                "kitty"
                "neovim"
                "nixcord"
                "shell"
                "ssh"
                "zed"
            ];
        };

        # Set a formatter for both the system architectures im using
        formatter = {
            aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
            x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        };
    };
}
