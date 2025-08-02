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
      url = "github:kaylorben/nixcord";
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

    darwinConfigurations.macbook-pro-m1 = mkSystem "macbook-pro-m1" {
      system = "aarch64-darwin";
      user = "example-user"; # your username here
      # Home manager modules you want to include as defined in ./home
      hm-modules = [ # modules are loaded from ./home/*
        "git"
        "kitty" # installs kitty and ghostty config
        "ghostty"
        "shell"
        "ssh"
        "zed" # installs neovim and zed es text editors
        "neovim"
      ];
    };

    # Set a formatter for both the system architectures im using
    formatter = {
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
  };
}
