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
  ];
  nix-homebrew = {
    enable = true; # Enable Homebrew management via Nix
    enableRosetta = false; # Do not install Intel Homebrew on Apple Silicon
    inherit user; # Set the Homebrew owner
    mutableTaps = false; # Make Homebrew taps declarative
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
  };
}
