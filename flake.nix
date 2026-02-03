{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M4";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nixkit = {
      url = "github:frostplexx/nixkit";
      # url = "path:/Users/daniel/Developer/github.com/frostplexx/nixkit";
    };

    lazykeys = {
      url = "github:frostplexx/lazykeys";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ==== Neovim ====
    neovim-nightly-overlay = {
      #TODO: switch to official when its fixed
      url = "github:Prince213/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ========================

    # ==== Homebrew Taps ====
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    jankyborders = {
      url = "github:FelixKratz/homebrew-formulae";
      flake = false;
    };

    # ========================
  };

  outputs = {nixpkgs, ...} @ inputs: let
    overlays = [
      inputs.nixkit.overlays.default
      (_final: prev: {
        kitty = prev.kitty.overrideAttrs (_oldAttrs: {
          doCheck = false;
        });
      })
    ];

    mkSystem = import ./lib/mksystem {
      inherit overlays nixpkgs inputs;
    };
  in {
    nixosConfigurations.hl-vm-gpu = mkSystem "hl-vm-gpu" {
      system = "x86_64-linux";
      user = "daniel";
      # Home manager modules you want to include as defined in ./home
      hm-modules = [
        "git"
        "kitty"
        "neovim"
        "neovim"
        "nixcord"
        "spotify"
        "ssh"
      ];
    };

    darwinConfigurations.macbook-m4-pro = mkSystem "macbook-m4-pro" {
      system = "aarch64-darwin";
      user = "daniel";
      # Home manager modules you want to include as defined in ./home
      hm-modules = [
        # "aerospace"
        "ghostty"
        "git"
        "kitty"
        "neovim"
        "nixcord"
        "shell"
        "spotify"
        "ssh"
        # "zed"
        "skhd"
        "zen"
      ];
      # Set your global accent color here (hex without #)
      accent_color = "cba6f7"; # mauve
      transparent_terminal = false;
    };

    # Set a formatter for both the system architectures im using
    formatter = {
      aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
      x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
    };
  };
}
