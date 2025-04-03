{
  config,
  pkgs,
  ...
}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "273019910c1111a388dd20e057606016f4bd0d17";
    hash = "sha256-80mR86UWgD11XuzpVNn56fmGRkvj0af2cFaZkU8M31I=";
  };

  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "68326b4ca4b5b66da3d4a4cce3050e5e950aade5";
    hash = "sha256-nhIhCMBqr4VSzesplQRF6Ik55b3Ljae0dN+TYbzQb5s=";
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
    initExtraFirst = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
    initExtra = builtins.readFile ./initExtra.zsh;
    completionInit = builtins.readFile ./completions.zsh;

    shellAliases = {
      v = "nvim";
      g = "lazygit";
      s = "spotify_player";
      c = "clear";
      q = "exit";
      p = "cd $(ls -d -1 ~/Developer/* |fzf); wezterm cli split-pane --cwd $PWD --top --percent 80 -- vim .";
      cat = "bat";
      tree = "eza --icons --git --header --tree";
      vimdiff = "nvim -d";
      cd = "z";
      copy = "rsync -avz --partial --progress";
      transfer = "kitten transfer --direction=receive";
      compress_to_mp4 = "~/dotfiles.nix/home/shell/scripts/compress_mp4.sh";
      ssh = "~/dotfiles.nix/home/shell/scripts/ssh.sh";
      ff = "~/dotfiles.nix/home/shell/scripts/window_select.sh";
      shinit = "~/dotfiles.nix/home/shell/scripts/shell_select.sh";
      yb = "yabai --restart-service; sudo yabai --load-sa; skhd --restart-service";
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

  xdg.configFile = {
    #Btop theme
    "btop/themes/catppuccin-mocha.theme" = {
      source = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/catppuccin_mocha.theme";
        sha256 = "sha256-THRpq5vaKCwf9gaso3ycC4TNDLZtBB5Ofh/tOXkfRkQ=";
      };
    };
  };

  # Shell utilities
  programs = {
    # Better cd
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin-mocha";
        theme_background = false;
        vim_keys = false;
        update_ms = 700;
      };
    };

    # Better ls
    eza = {
      enable = true;
      enableZshIntegration = true;
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
            repo = "bat"; # Bat uses sublime syntax for its themes
            rev = "699f60fc8ec434574ca7451b444b880430319941";
            sha256 = "sha256-6fWoCH90IGumAMc4buLRWL0N61op+AuMNN9CAR9/OdI=";
          };
          file = "Catppuccin Mocha.tmTheme";
        };
      };
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
        flavor = {
          dark = "catppuccin-mocha";
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
          rev = "6c639b474aabb17f5fecce18a4c97bf90b016512";
          hash = "sha256-bhLUziCDnF4QDCyysRn7Az35RAy8ibZIVUzoPgyEO1A=";
        };
      };
      flavors = {
        catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
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
            run = "plugin max-preview";
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

    spotify-player = {
      enable = true;
      settings = {
        theme = "default";
        border_type = "Rounded";
        progress_bar_type = "Line";
        playback_window_position = "Top";
        play_icon = "";
        pause_icon = "";
        liked_icon = "";
        copy_command = {
          command = "wl-copy";
          args = [];
        };
        client_id_command = "~/dotfiles.nix/home/programs/shell/spotify_client_id.sh";
        client_id = "d5b77903b8f34340a4d35a044fcc73c5";
        device = {
          audio_cache = true;
          normalization = true;
          volume = 50;
        };
      };
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

    fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = pkgs.fetchurl {
            url = "https://daiderd.com/nix-darwin/images/nix-darwin.png";
            hash = "sha256-CeA0LbC3q6HMZuqJ9MHncI5z8GZ/EMAn7ULjiIX0wH4=";
          };
          type = "kitty-direct";
          padding = {
            right = 3;
            top = 2;
            bottom = 2;
          };
        };
        display = {
          color = {
            keys = "blue";
            title = "red";
          };
          constants = [
            "──────────────────────────"
          ];
        };
        modules = [
          {
            type = "custom";
            format = "┌{$1} {#1}Hardware{#} ─{$1}┐";
          }
          {
            type = "title";
            format = "{1}@{2}";
            key = "  {#cyan}{icon} Title";
            color = "blue";
          }
          {
            type = "host";
            key = "  {#cyan}{icon} Host";
          }
          {
            type = "display";
            key = " {#cyan} {icon} Display";
          }
          {
            type = "cpu";
            key = "  {#cyan}{icon} CPU";
            showPeCoreCount = true;
            temp = true;
            format = "{name}  {#2}[C:{core-types}] [{freq-max}]";
          }
          {
            type = "gpu";
            key = "  {#cyan}{icon} GPU";
            detectionMethod = "auto";
            driverSpecific = true;
            format = "{name}  {#2}[C:{core-count}]{?frequency} [{frequency}]{?} [{type}]";
          }
          {
            type = "memory";
            key = "  {#cyan}{icon} Memory";
            format = "{used} / {total} ({percentage})";
          }

          {
            type = "disk";
            key = "  {#cyan}{icon} Disk";
            format = "{size-used} / {size-total} ({size-percentage})";
            folders = ["/" "/home"];
          }

          {
            type = "custom";
            format = "├{$1} {#1}System ───{#}{$1}┤";
          }
          {
            type = "os";
            key = "  {#green}{icon} OS";
            format = "{?pretty-name}{pretty-name}{?}{/pretty-name}{name}{/} {codename}  {#2}[v{version}] [{arch}]";
          }
          {
            type = "kernel";
            key = "  {#green}{icon} Kernel";
            format = "{sysname}  {#2}[v{release}]";
          }
          {
            type = "de";
            key = "  {#green}{icon} DE";
          }
          {
            type = "wm";
            key = "  {#green}{icon} WM";
          }
          {
            type = "uptime";
            key = "  {#green}{icon} Uptime";
            format = "{?days}{days} Days + {?}{hours}:{minutes}:{seconds}";
          }

          {
            type = "custom";
            format = "├{$1} {#1}Software{#} ─{$1}┤";
          }
          {
            type = "packages";
            key = "  {#yellow}{icon} Packages";
            format = "{9} total ({1} pkg, {2} cask, {3} flatpak, {6} snap)";
          }
          {
            type = "shell";
            key = "  {#yellow}{icon} Shell";
            format = "{pretty-name}  {#2}[v{version}] [PID:{pid}]";
          }
          {
            type = "terminal";
            key = "  {#yellow}{icon} Terminal";
            format = "{pretty-name}  {#2}[{version}] [PID:{pid}]";
          }
          {
            type = "font";
            key = "  {#yellow}{icon} Font";
          }

          {
            type = "custom";
            format = "├{$1} {#1}Network{#} ──{$1}┤";
          }
          {
            type = "localip";
            key = "  {#magenta}{icon} Local IP";
            showPrefixLen = true;
            showIpv4 = true;
            showIpv6 = false;
            showMtu = true;
            format = "{ifname}: {ipv4}  {#2}[MTU:{mtu}]";
          }
          {
            type = "publicip";
            key = "  {#magenta}{icon} Public IPv4";
            ipv6 = false;
            format = "{ip}  {#2}[{location}]";
          }
          {
            type = "publicip";
            key = "  {#magenta}{icon} Public IPv6";
            ipv6 = true;
            format = "{ip}  {#2}[{location}]";
          }
          {
            type = "wifi";
            key = "  {#magenta}{icon} Wifi";
            format = "{ssid}";
          }

          {
            type = "custom";
            key = "{#}└─{$1}──────────{$1}┘";
            format = "";
          }
          "break"
          "colors"
        ];
        palette = "supply";
      };
    };
    # starship = {
    #   enable = true;
    #   enableZshIntegration = true;
    #   settings = {
    #     add_newline = false;
    #     scan_timeout = 10;
    #   };
    # };
  };
}
