{ config, pkgs, lib, ... }:
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
      addpkg = "$HOME/dotfiles/home/programs/shell/package.sh"; # Package manager for my flake; Lets you update, install, search, uninstall and list packages from nix and homebrew

      # More aliases for other apps
      ls = "eza --icons=auto --git --header";
      cat = "bat --theme=base16-256";
      tree = "eza --icons --git --header --tree";
      vimdiff = "nvim -d";
      cd = "z";
      copy = "rsync -avz --partial --progress";
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



  # Ensure cache directory exists for instant prompt
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
      enableZshIntegration = true;
      package = pkgs.yazi.override {
        _7zz = pkgs._7zz.override {
          useUasm = pkgs.stdenv.isLinux;
        };
      };
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
      enableTransience = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        scan_timeout = 10;
      };
    };
  };
}
