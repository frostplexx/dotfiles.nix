{pkgs, ...}: {
    programs = {
        # starship = {
        #     enable = true;
        #     enableFishIntegration = true;
        #     enableTransience = true;
        # };

        fish = {
            enable = true;
            plugins = with pkgs.fishPlugins; [
                {
                    name = "macos";
                    inherit (macos) src;
                }
                {
                    name = "tide";
                    inherit (tide) src;
                }
                {
                    name = "forgit";
                    inherit (forgit) src;
                }
            ];

            shellAliases = {
                v = "nvim";
                g = "lazygit";
                c = "clear";
                q = "exit";
                s = "kitten ssh";
                p = "cd $(ls -d -1 ~/Developer/* |fzf); kitten @ launch --location=hsplit --bias=20 --cwd $PWD;nvim .";
                cat = "bat";
                tree = "eza --icons --git --header --tree";
                vimdiff = "nvim -d";
                cd = "z";
                gt = "git-forgit";
                wake = "nix run nixpkgs#fortune; printf '\n\nKeeping PC awake...\a'; caffeinate -d -i -m -s";
                ghd = "gh dash";
            };

            shellAbbrs = {
                copy = "rsync -avz --partial --progress";
                transfer = "kitten transfer --direction=receive";
                nhs = "nh search";
                j = "just";
                nixs = "nix shell nixpkgs#";
                nixr = "nix run nixpkgs#";
            };

            shellInit = builtins.readFile ./shellInit.fish;
        };
    };

    # Themes cant be installed as plugins so I load it directly into the themes folder
    xdg.configFile = {
        "fish/themes/Catppuccin Mocha.theme" = {
            text = builtins.readFile (pkgs.fetchurl {
                url = "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
                sha256 = "kdA9Vh23nz9FW2rfOys9JVmj9rtr7n8lZUPK8cf7pGE=";
            });
        };
    };

    home.file = {
        ".fish_scripts" = {
            recursive = true;
            source = ./scripts;
        };
    };

    # Tide config command:
    # tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=Yes
    # Custom activation script to configure tide
    # home.activation.configureTide = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #     # Only run if we're inside kitty terminal
    #     if [ "$TERM" = "xterm-kitty" ] || [ -n "$KITTY_WINDOW_ID" ]; then
    #       # Launch a kitty overlay terminal to configure tide without disturbing the current session
    #       $DRY_RUN_CMD ${pkgs.kitty}/bin/kitten @ launch --type=overlay --title="Tide Configuration" --copy-env -- ${pkgs.fish}/bin/fish -C "
    #         set -x SKIP_FF 1
    #         set -x PATH $PATH:/usr/bin
    #         # Configure tide with initial settings
    #         tide configure --auto --style=Lean --prompt_colors='16 colors' --show_time=No --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Few icons' --transient=Yes
    #         # echo 'Tide configuration complete. Window will close in 1 seconds.'
    #         # sleep 1
    #         exit 0
    #       "
    #     fi
    # '';
}
