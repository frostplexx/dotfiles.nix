{ inputs, user }:
{
  imports = [
    inputs.nix-homebrew.darwinModules.nix-homebrew
    inputs.lazykeys.darwinModules.default
    inputs.nixkit.darwinModules.default
  ];
  nix-homebrew = {
    enable = true;
    enableRosetta = false;
    inherit user;
    mutableTaps = false;
    taps = with inputs; {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };
  };
}
