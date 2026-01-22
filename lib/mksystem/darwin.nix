# Darwin (macOS) specific system modules and options.
# This is imported only when building for Darwin systems.
{
  inputs,
  user,
}: {
  imports = [
    # Homebrew integration for Nix-Darwin
    inputs.nix-homebrew.darwinModules.nix-homebrew
    # LazyKeys for keyboard shortcuts
    inputs.lazykeys.darwinModules.default
    # NixKit Darwin modules
    inputs.nixkit.darwinModules.default
    # Determinate integration
    inputs.determinate.darwinModules.default
  ];

  determinateNix.customSettings = {
    experimental-features = "nix-command flakes parallel-eval impure-derivations";
    lazy-trees = true;
    warn-dirty = false;
    substituters = "https://nix-community.cachix.org https://cache.nixos.org";
    trusted-public-keys = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
    extra-trusted-users = "root ${user}";
    eval-cores = 0; # Evaluate across all cores
    auto-optimise-store = true;
    max-jobs = "auto";
  };
  nix-homebrew = {
    enable = true; # Enable Homebrew management via Nix
    enableRosetta = false; # Do not install Intel Homebrew on Apple Silicon
    inherit user; # Set the Homebrew owner
    mutableTaps = false; # Make Homebrew taps declarative
    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "FelixKratz/homebrew-formulae" = jankyborders;
    };
  };
}
