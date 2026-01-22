{user, ...}: {
  imports = [./vars.nix];
  home = {
    username = user;
    stateVersion = "23.11";
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles.nix";
      EDITOR = "nvim";
    };
  };

  # home.activation.fetchAgeKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     ${fetchAgeKey}/bin/fetch-age-key
  # '';

  programs = {
    home-manager.enable = true; # Let Home Manager manage itself
  };
}
