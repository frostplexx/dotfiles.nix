{user, ...}: {
    home = {
        username = user;
        stateVersion = "23.11";
        sessionVariables = {
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

    programs = {
        home-manager.enable = true; # Let Home Manager manage itself
        # zsh.enable = true; # Basic zsh configuration
    };
}
