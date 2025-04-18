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
