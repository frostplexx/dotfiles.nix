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
            url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.0.tar.gz";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        darwin = {
            url = "github:nix-darwin/nix-darwin/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # Declaratively manage homebrew
        nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

        # Needed for firefox addons
        nurpkgs = {
            url = "github:nix-community/NUR";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        _1password-shell-plugins.url = "github:1Password/shell-plugins";

        nixcord = {
            url = "github:kaylorben/nixcord";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixkit = {
            url = "github:frostplexx/nixkit";
            # or for local development:
            # url = "path:/Users/daniel/Developer/nixkit";
        };

        lazykeys = {
            url = "github:frostplexx/lazykeys";
        };

        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

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

    };

    outputs = {nixpkgs, ...} @ inputs: let
        overlays = [
            inputs.nurpkgs.overlays.default
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
                "firefox"
                "git"
                "i3"
                "kitty"
                "neovim"
                "nixcord"
                "shell"
                "ssh"
            ];
        };

        darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
            system = "aarch64-darwin";
            user = "daniel";
            # Home manager modules you want to include as defined in ./home
            hm-modules = [
                "firefox"
                "git"
                "kitty"
                "neovim"
                "nixcord"
                "shell"
                "ssh"
            ];
        };

        # Set a formatter for both the system architectures im using
        formatter = {
            aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
            x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        };
    };
}
