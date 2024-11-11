{ config, pkgs, ... }:
{

  programs.zsh = {
    enable = true;

    # Load some plugins and shit
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;


    # Load extra plugins
    plugins = [
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh-autopair/autopair.zsh";
      }
    ];

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
      y = "~/dotfiles.nix/home/programs/shell/scripts/yazi.zsh";
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
    ".hushlogin".text = builtins.readFile ./hushlogin;
  };


  # Install required packages
  home.packages = with pkgs; [
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-autopair
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

    # Terminal file manager
    yazi = {
      enable = true;
      package = pkgs.yazi.override {
        _7zz = pkgs._7zz.override {
          useUasm = pkgs.stdenv.isLinux;
        };
      };
      settings = {
        manager = {
          layout = [
            1
            4
            3
          ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "mtime";
          show_hidden = true;
          show_symlink = true;
        };

        preview = {
          image_filter = "lanczos3";
          image_quality = 90;
          tab_size = 1;
          max_width = 600;
          max_height = 900;
          cache_dir = "";
          ueberzug_scale = 1;
          ueberzug_offset = [
            0
            0
            0
            0
          ];
        };

        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };
      };
    };



    # Automatically enable dev shells
    direnv.enable = true;


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
