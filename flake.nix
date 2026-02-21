{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M4";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-nixos-25-11 = {
      url = "github:nixos/nixpkgs/nixos-25.11";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-nixos-25-11";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nixcord.url = "github:kaylorben/nixcord";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    nixkit.url = "github:frostplexx/nixkit";

    lazykeys.url = "github:frostplexx/lazykeys";

    tidaLuna.url = "github:Inrixia/TidaLuna";
    # tidaLuna.url = "git+file:///Users/daniel/Developer/github.com/frostplexx/TidaLuna";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    nixos-anywhere = {
      url = "github:nix-community/nixos-anywhere";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs-nixos-25-11";
      inputs.home-manager.follows = "home-manager-stable";
    };

    # ==== Neovim ====
    neovim-nightly-overlay = {
      url = "github:Prince213/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
