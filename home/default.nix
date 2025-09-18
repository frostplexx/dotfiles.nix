{user, pkgs, assets, ...}: {
    home = {
        username = user;
        stateVersion = "23.11";
        sessionVariables = {
            NH_FLAKE = "$HOME/dotfiles.nix";
            EDITOR = "nvim";
        };
    };

    # sops = {
    #     age.keyFile = keyPath;
    #     age.generateKey = false;
    # };
    #
    # home.activation.fetchAgeKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     ${fetchAgeKey}/bin/fetch-age-key
    # '';

    stylix = {
      enable = true;
      autoEnable = true;
      targets = {
        fish.enable = true;
        neovim.enable = false;
        yazi.enable = true;
      };
    };

    programs = {
        home-manager.enable = true; # Let Home Manager manage itself
        # zsh.enable = true; # Basic zsh configuration
    };
}
