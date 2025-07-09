{pkgs, ...}: {
    programs = {
        starship = {
            enable = true;
            enableFishIntegration = true;
            enableTransience = true;
        };

        fish = {
            enable = true;

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
                j = "jinx";
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
}
