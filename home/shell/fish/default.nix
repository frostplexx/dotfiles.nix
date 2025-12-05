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
        ghi = "gh issue";
        ghp = "gh pr";
        ghb = "gh browse";
      };

      shellInit = builtins.readFile ./shellInit.fish;
    };
  };

  # Themes cant be installed as plugins so I load it directly into the themes folder
  xdg.configFile = {
    "fish/themes/Catppuccin Mocha.theme" = {
      text = builtins.readFile (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
        sha256 = "sha256-8Ny82/W2yDWdtcKGxl6EO1jXgGJF2R6GbX2khTZs+78=";
      });
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
