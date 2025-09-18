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
                s = "ssh";
                p = "project_selector";
                cat = "bat";
                tree = "eza --icons --git --header --tree";
                vimdiff = "nvim -d";
                cd = "z";
            };

            shellAbbrs = {
                copy = "rsync -avz --partial --progress";
                transfer = "kitten transfer --direction=receive";
                ns = "jinx search";
                j = "jinx";
                nixs = "nix shell nixpkgs#";
                nixr = "nix run nixpkgs#";
            };

            shellInit = builtins.readFile ./shellInit.fish;
        };
    };

    #
    home.file = {
        ".fish_scripts" = {
            recursive = true;
            source = ./scripts;
        };
    };
}
