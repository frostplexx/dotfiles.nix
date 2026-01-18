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
        p = "project_selector";
        cat = "bat";
        tree = "eza --icons --git --header --tree";
        vimdiff = "nvim -d";
        cd = "z";
        avante = "nvim -c 'lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)'";
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
      text = builtins.readFile (
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
          sha256 = "sha256-RAj93cAYcZxs28TrN90c2rfFpQ0sR2VfhC1HazVrpPw=";
        }
      );
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
