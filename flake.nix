{
    description = "Unified configuration for NixOS gaming PC and MacBook Pro M1";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
            url = "github:nix-community/home-manager/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

        darwin = {
            # url = "github:nix-darwin/nix-darwin/master";
            url = "github:dwt/nix-darwin/application-linking-done-right";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        mac-app-util.url = "github:hraban/mac-app-util";

        # Declaratively manage homebrew
        nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

        _1password-shell-plugins.url = "github:1Password/shell-plugins";

        nixcord = {
            # TODO: change back once https://github.com/KaylorBen/nixcord/pull/119 has been merged
            url = "github:kaylorben/nixcord";
            # url = "github:builtbyvys/nixcord";
        };

        spicetify-nix.url = "github:Gerg-L/spicetify-nix";

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
    };

    outputs = {nixpkgs, ...} @ inputs: let
        overlays = [
        ];

        mkSystem = import ./lib/mksystem {
            inherit overlays nixpkgs inputs;
        };
    in {
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
                "zed"
                "spotify"
            ];
        };

        nixosConfigurations.pc-nixos-gaming = mkSystem "pc-nixos-gaming" {
            system = "x86_64-linux";
            user = "daniel";
            # Home manager modules you want to include as defined in ./home
            hm-modules = [
                "git"
                "neovim"
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
                "ghostty"
                "neovim"
                "nixcord"
                "shell"
                "ssh"
                "spotify"
            ];
        };

        # Set a formatter for both the system architectures im using
        formatter = {
            aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
            x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
        };
    };
}
