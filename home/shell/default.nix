{
    pkgs,
    config,
    ...
}: {
    imports = [
        ./btop.nix
        ./fastfetch.nix
        ./fish
        ./spotify_player.nix
        ./yazi.nix
        ./lazygit.nix
    ];

    # sops.secrets = {
    #     "wtfis.env" = {
    #         sopsFile = ./wtfis.env;
    #         key = "";
    #         format = "dotenv";
    #         path = "${config.home.homeDirectory}/.env.wtfis"; # Place it directly where needed
    #     };
    #
    #     "spotify_player_credentials.json" = {
    #         sopsFile = ./spotify_player_credentials.json;
    #         key = "";
    #         format = "json";
    #         path = "~/.cache/spotify-player/credentials.json"; # Place it directly where needed
    #     };
    # };

    home.file = {
        # Hushlogin to not show login message
        ".hushlogin".text = "";
    };

    # Shell utilities
    programs = {
        # Better cd
        zoxide = {
            enable = true;
            enableFishIntegration = true;
        };

        # Better ls
        eza = {
            enable = true;
            enableFishIntegration = true;
            git = true;
            icons = "auto";
            colors = "auto";
            extraOptions = [
                "--group-directories-first"
                "--header"
            ];
        };

        # Better cat
        bat = {
            enable = true;
        };

        # Better find
        fd = {
            enable = true;
        };

        # Better grep
        ripgrep = {
            enable = true;
        };

        direnv = {
            enable = true;
            # Fish shell integration is bugged or something:
            # https://github.com/nix-community/home-manager/issues/2357
            # enableFishIntegration = true;
            nix-direnv = {
                enable = true;
            };
            silent = true;
        };

        # Fuzzy finder
        fzf = {
            enable = true;
            enableFishIntegration = true;
            defaultCommand = "fd --type f"; # Faster than find
            defaultOptions = [
                "--height 40%"
                "--layout=reverse"
            ];
        };
    };
}
