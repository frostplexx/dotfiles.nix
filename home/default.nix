{
  user,
  config,
  ...
}: {
  home = {
    username = user;
    stateVersion = "23.11";
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles.nix";
      EDITOR = "nvim";
    };
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/git.yaml;
  };

  programs = {
    home-manager.enable = true; # Let Home Manager manage itself
    # zsh.enable = true; # Basic zsh configuration
    opencode = {
      enable = true;
      settings = {
        theme = "catppuccin";
        autoshare = false;
        autoupdate = true;
        model = "anthropic/claude-sonnet-4-5";
      };
    };
  };
}
