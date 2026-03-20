{
  description = "Unified configuration for NixOS gaming PC and MacBook Pro M4";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nixpkgs.url = "git+file:///Users/daniel/Developer/github.com/frostplexx/nixpkgs";

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

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        # IMPORTANT: To ensure compatibility with the latest Firefox version, use nixpkgs-unstable.
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nixcord.url = "github:kaylorben/nixcord";

    nixkit = {
      url = "github:frostplexx/nixkit";
      # url = "git+file:///Users/daniel/Developer/github.com/frostplexx/nixkit";
    };

    lazykeys.url = "github:frostplexx/lazykeys";

    tidaluna.url = "github:frostplexx/TidaLuna/flake";
    # tidaluna.url = "github:Inrixia/TidaLuna";
    # tidaluna.url = "git+file:///Users/daniel/Developer/github.com/frostplexx/TidaLuna";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fff-nvim = {
      url = "github:dmtrKovalenko/fff.nvim";
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
