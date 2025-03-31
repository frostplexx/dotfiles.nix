# Home Manager configuration with module selection
# Note: This file is imported from home-manager and defines the base configuration
{user, ...}: {
  # Global home settings

  home = {
    username = user;
    stateVersion = "23.11";
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles.nix";
      EDITOR = "nvim";
    };
  };
  programs = {
    home-manager.enable = true; # Let Home Manager manage itself
    zsh.enable = true; # Basic zsh configuration
  };
}
