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

        _1password-shell-plugins = {
            # enable 1Password shell plugins for bash, zsh, and fish shell
            enable = true;
            # the specified packages as well as 1Password CLI will be
            # automatically installed and configured to use shell plugins
            plugins = with pkgs; [gh hcloud];
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
            config = {
                theme = "catppuccin-mocha";
            };
            themes = {
                catppuccin-mocha = {
                    src = pkgs.fetchFromGitHub {
                        owner = "catppuccin";
                        repo = "bat"; # Bat uses sublime syntax for its themes
                        rev = "699f60fc8ec434574ca7451b444b880430319941";
                        sha256 = "1lirgwgh2hnz6j60py19bbmhvgaqs7i6wf6702k6n83lgw4aixg9";
                    };
                    file = "themes/Catppuccin Mocha.tmTheme";
                };
            };
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
            enable = false;
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
                # Catppuccin colors: https://github.com/catppuccin/fzf
                "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
                "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
                "--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
                "--color=selected-bg:#45475a"
                "--color=border:#313244,label:#cdd6f4"
            ];
        };
    };
}
