{pkgs, ...}: let
  yazi-plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "de53d90cb2740f84ae595f93d0c4c23f8618a9e4";
    hash = "sha256-ixZKOtLOwLHLeSoEkk07TB3N57DXoVEyImR3qzGUzxQ=";
  };

  yazi-flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "d3fd3a5d774b48b3f88845f4f0ae1b82f106d331";
    hash = "sha256-RtunaCs1RUfzjefFLFu5qLRASbyk5RUILWTdavThRkc=";
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
            name ="*";
            run = "git";
          }
          {
            id = "git";
            name ="*/";
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
      starship = pkgs.fetchFromGitHub {
        owner = "Rolv-Apneseth";
        repo = "starship.yazi";
        rev = "a63550b2f91f0553cc545fd8081a03810bc41bc0";
        hash = "sha256-PYeR6fiWDbUMpJbTFSkM57FzmCbsB4W4IXXe25wLncg=";
      };
    };
    flavors = {
      catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
    };

    initLua = ''
      require("git"):setup()
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
