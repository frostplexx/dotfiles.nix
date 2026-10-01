_: {
  flake.homeManagerModules.shell = {
    pkgs,
    lib,
    inputs,
    ...
  }: {
    home.file = {
      ".hushlogin".text = "";
    };

    programs = {
      # Starship prompt
      starship = {
        enable = true;
        enableFishIntegration = true;
        enableTransience = true;
        settings = {
          command_timeout = 2000;

          # Custom module to display work topic in the prompt
          custom.work_topic = {
            command = ''echo "$WORK_TOPIC"'';
            when = ''[ -n "$WORK_TOPIC" ]'';
            symbol = "🎯 ";
            style = "bold purple";
            format = "[$symbol$output]($style) ";
          };
        };
      };

      man.package = pkgs.man;

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
          # "What will this do?" — gloss the command line you are about to run.
          "alt-/" = {
            command = ''
              set -l cmd (commandline | string collect); if test -n "$cmd"; echo; set_color brblack; printf %s "$cmd" | pq "One line: what does this shell command do? Name any deletion, overwrite, or network side effect explicitly."; set_color normal; commandline -f repaint; end
            '';
            mode = "insert";
          };
        };

        shellAliases = {
          v = "nvim";
          g = "lazygit";
          c = "clear";
          q = "exit";
          s = "ssh";
          boo = "ghostty +boo";
          p = "project_selector";
          cat = "bat";
          tree = "eza --icons --git --header --tree";
          vimdiff = "nvim -d";
          cd = "z";
          nurl = "nix run nixpkgs#nurl --";
          compress = "tar -cf";
          untar = "tar -xf";
        };

        shellAbbrs = {
          ns = "jinx search";
          j = "jinx";
          chex = "chmod +x";
          nixs = "nix shell nixpkgs#";
          ghi = "gh issue";
          ghp = "gh pr";
          ghb = "gh browse";
        };

        interactiveShellInit = builtins.readFile ./shellInit.fish;
        shellInitLast =
          /*
          fish
          */
          ''
            fish_config theme choose "Catppuccin Mocha"
          '';
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
            src = inputs.catppuccin-bat;
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
    };

    # Fish theme
    xdg.configFile = {
      "fish/themes/Catppuccin Mocha.theme" = {
        source = "${inputs.catppuccin-fish}/themes/catppuccin-mocha.theme";
      };
    };

    # Fish scripts: one function per file, autoloaded on first call instead
    # of being sourced on every shell start.
    xdg.configFile."fish/functions" = {
      recursive = true;
      source =
        if pkgs.stdenv.hostPlatform.isDarwin
        then ./scripts
        # tmutil (Time Machine) is macOS-only
        else
          lib.fileset.toSource {
            root = ./scripts;
            fileset = lib.fileset.difference ./scripts ./scripts/tm_exclude_node_modules.fish;
          };
    };
  };
}
