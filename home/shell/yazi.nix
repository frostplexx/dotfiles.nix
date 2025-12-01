{pkgs, ...}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "eaf6920b7439fa7164a1c162a249c3c76dc0acd9";
    hash = "sha256-B6zhZfp3SEaiviIzosI2aD8fk+hQF0epOTKi1qm8V3E=";
  };

  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "3edeb49597e1080621a9b0b50d9f0a938b8f62bb";
    hash = "sha256-twgXHeIj52EfpMpLrhxjYmwaPnIYah3Zk/gqCNTb2SQ=";
  };
in {
  # Terminal file manager
  programs. yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";
    package = pkgs.yazi.override {
      _7zz = pkgs._7zz.override {
        useUasm = pkgs.stdenv.isLinux;
      };
    };

    settings = {
      mgr = {
        sort_by = "natural";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "mtime";
        show_hidden = true;
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
      smart-filter = "${yazi-plugins}/smart-filter.yazi";
      git = "${yazi-plugins}/git.yazi";
      jump-to-char = "${yazi-plugins}/jump-to-char.yazi";
      no-status = "${yazi-plugins}/no-status.yazi";
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "d7056e37c853048a39b1fb9243d8654e60311d79";
        hash = "sha256-zlyJrBBUTeeGB69pMel+QWU/ivbUfzBJhGJy+yoHoaE=";
      };
    };
    flavors = {
      catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
    };

    initLua = ''
      require("git"):setup()
      require("no-status"):setup()
      require("starship"):setup({
          -- Hide flags (such as filter, find and search). This is recommended for starship themes which
          -- are intended to go across the entire width of the terminal.
          hide_flags = false, -- Default: false
          -- Whether to place flags after the starship prompt. False means the flags will be placed before the prompt.
          flags_after_prompt = true, -- Default: true
          -- Custom starship configuration file to use
          config_file = "~/.config/starship_full.toml", -- Default: nil
      })
    '';

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "f";
          run = "plugin jump-to-char";
          desc = "Jump to char";
        }
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
}
