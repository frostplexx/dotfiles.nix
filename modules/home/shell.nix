_: {
  flake.modules.homeManager.shell = {pkgs, ...}: {
    home.file = {
      ".hushlogin".text = "";
    };

    programs = {
      # Starship prompt
      starship = {
        enable = true;
        enableFishIntegration = true;
        enableTransience = true;
      };

      # Fish shell
      fish = {
        enable = true;

        binds = {
          "alt-h" = {
            command = ''
              commandline -f beginning-of-line; set -l cmd (commandline -t); commandline ""; man $cmd; commandline -f repaint
            '';
            mode = "insert";
          };
          "alt-shift-b" = {
            command = "fish_commandline_append bat";
            mode = "insert";
          };
        };

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
          chex = "chmod +x";
          nixs = "nix shell nixpkgs#";
          nixr = "nix run nixpkgs#";
          ghi = "gh issue";
          ghp = "gh pr";
          ghb = "gh browse";
        };

        shellInit = builtins.readFile ./fish/shellInit.fish;
      };

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
        config = {
          theme = "catppuccin-mocha";
        };
        themes = {
          catppuccin-mocha = {
            src = pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "bat";
              rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
              sha256 = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
            };
            file = "themes/Catppuccin Mocha.tmTheme";
          };
        };
      };

      # Better find
      fd.enable = true;

      # Better grep
      ripgrep.enable = true;

      # Direnv
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };

      # Fuzzy finder
      fzf = {
        enable = true;
        enableFishIntegration = true;
        defaultCommand = "fd --type f";
        defaultOptions = [
          "--height 40%"
          "--layout=reverse"
          "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8"
          "--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc"
          "--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
          "--color=selected-bg:#45475a"
          "--color=border:#313244,label:#cdd6f4"
        ];
      };

      # Yazi file manager
      yazi = {
        enable = true;
        enableFishIntegration = true;
        shellWrapperName = "y";
        settings = {
          manager = {
            show_hidden = true;
            sort_by = "natural";
            sort_dir_first = true;
          };
        };
      };

      # Lazygit
      lazygit = {
        enable = true;
        settings = {
          gui.theme = {
            lightTheme = false;
            activeBorderColor = ["#cba6f7" "bold"];
            inactiveBorderColor = ["#a6adc8"];
            optionsTextColor = ["#89b4fa"];
            selectedLineBgColor = ["#313244"];
            cherryPickedCommitBgColor = ["#45475a"];
            cherryPickedCommitFgColor = ["#cba6f7"];
            unstagedChangesColor = ["#f38ba8"];
            defaultFgColor = ["#cdd6f4"];
            searchingActiveBorderColor = ["#f9e2af"];
          };
        };
      };

      # Btop
      btop = {
        enable = true;
        settings = {
          color_theme = "catppuccin_mocha";
          theme_background = false;
          truecolor = true;
          rounded_corners = true;
          vim_keys = true;
        };
      };

      # Fastfetch
      fastfetch = {
        enable = true;
        settings = {
          logo = {
            type = "small";
          };
          display = {
            separator = " ";
          };
          modules = [
            "title"
            "separator"
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "terminal"
            "cpu"
            "gpu"
            "memory"
            "disk"
            "break"
            "colors"
          ];
        };
      };
    };

    # Fish theme
    xdg.configFile = {
      "fish/themes/Catppuccin Mocha.theme" = {
        source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/fish/main/themes/Catppuccin%20Mocha.theme";
          sha256 = "sha256-RAj93cAYcZxs28TrN90c2rfFpQ0sR2VfhC1HazVrpPw=";
        };
      };
    };

    # Fish scripts
    home.file.".fish_scripts" = {
      recursive = true;
      source = ./fish/scripts;
    };
  };
}
