{
  config,
  pkgs,
  ...
}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "38418ddc9247de206645ed284c804b5e179452a1";
    hash = "sha256-cdPeIhtTzSYhJZ3v3Xlq8J3cOmR7ZiOGl5q48Qgthyk=";
  };
in {
  programs.zsh = {
    enable = true;

    # Load some plugins and shit
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

    # Load extra zsh configuration from initExtra.zsh
    initExtra = builtins.readFile ./initExtra.zsh;
    completionInit = builtins.readFile ./completions.zsh;

    shellAliases = {
      v = "nvim"; # Neovim quick alias
      g = "lazygit"; # Add lazygit alias
      c = "clear";
      q = "exit";

      # More aliases for other apps
      ls = "eza --icons=auto --git --header";
      cat = "bat --theme=base16-256";
      tree = "eza --icons --git --header --tree";
      vimdiff = "nvim -d";
      cd = "z";
      copy = "rsync -avz --partial --progress";
      transfer = "kitten transfer --direction=receive";
      compress_to_mp4 = "~/dotfiles.nix/home/programs/shell/scripts/compress_mp4.sh";
      ssh = "~/dotfiles.nix/home/programs/shell/scripts/ssh.sh";
      ff = "~/dotfiles.nix/home/programs/shell/scripts/window_select.sh";
      shinit = "~/dotfiles.nix/home/programs/shell/scripts/shell_select.sh";
    };

    # History Settings
    history = {
      save = 10000;
      size = 10000;
      path = "${config.xdg.cacheHome}/zsh/history";
      expireDuplicatesFirst = true;
      ignoreDups = true;
      share = true;
      extended = true;
    };
  };

  # Hushlogin to not show login message
  home.file = {
    ".hushlogin".text = "";
  };

  # Install required packages
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    zsh-autosuggestions
  ];

  # Shell utilities
  programs = {
    # Better cd
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    # Better ls
    eza = {
      enable = true;
      enableZshIntegration = true;
    };

    # Better cat
    bat = {
      enable = true;
    };

    fd = {
      enable = true;
    };

    # Terminal file manager
    yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "y";
      package = pkgs.yazi.override {
        _7zz = pkgs._7zz.override {
          useUasm = pkgs.stdenv.isLinux;
        };
      };

      settings = {
        manager = {
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "mtime";
          show_hidden = false;
          show_symlink = true;
        };

        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };

        plugin = {
          prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
            }
          ];
        };
      };

      plugins = {
        chmod = "${yazi-plugins}/chmod.yazi";
        full-border = "${yazi-plugins}/full-border.yazi";
        max-preview = "${yazi-plugins}/max-preview.yazi";
        smart-filter = "${yazi-plugins}/smart-filter.yazi";
        git = "${yazi-plugins}/git.yazi";
        starship = pkgs.fetchFromGitHub {
          owner = "Rolv-Apneseth";
          repo = "starship.yazi";
          rev = "main";
          sha256 = "sha256-sAB0958lLNqqwkpucRsUqLHFV/PJYoJL2lHFtfHDZF8=";
        };
      };

      initLua = ''
        require("full-border"):setup {
        	-- Available values: ui.Border.PLAIN, ui.Border.ROUNDED
        	type = ui.Border.ROUNDED,
        }
        require("starship"):setup()
        require("git"):setup()
      '';

      keymap = {
        manager.prepend_keymap = [
          {
            on = "T";
            run = "plugin --sync max-preview";
            desc = "Maximize or restore the preview pane";
          }
          {
            on = ["c" "h"];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = ["g" "i"];
            run = "cd '~/Library/Mobile Documents/com~apple~CloudDocs'";
            desc = "Go to iCloud";
          }
          {
            on = "F";
            run = "plugin smart-filter";
            desc = "Toggle smart filter";
          }
          {
            on = "<C-p>";
            run = ''
              shell 'qlmanage -p "$@"' --confirm
            '';
          }
        ];
      };
    };

    ripgrep = {
      enable = true;
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    # Fuzzy finder
    fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultCommand = "fd --type f"; # Faster than find
      defaultOptions = [
        "--height 40%"
        "--layout=reverse"
        "--color=spinner:#f4dbd6,hl:#ed8796"
        "--color=fg:#cad3f5,header:#cad3f5,info:#c6a0f6,pointer:#f4dbd6"
        "--color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"
      ];
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        scan_timeout = 10;
      };
    };
  };
}
