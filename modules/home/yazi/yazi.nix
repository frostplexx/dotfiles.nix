_: {
  flake.homeManagerModules.yazi = {pkgs, ...}: let
    yazi-flavors = pkgs.fetchFromGitHub {
      owner = "yazi-rs";
      repo = "flavors";
      rev = "06708015bfb53b169d99bb3907829f9175105d57";
      hash = "sha256-Gm6ThktOLUR+KDs6f3s1WCgrw2TOKQ4tolVvVdCxnCM=";
    };
  in {
    # Terminal file manager
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      shellWrapperName = "y";
      package = pkgs.yazi.override {
        _7zz = pkgs._7zz.override {
          useUasm = pkgs.stdenv.isLinux;
        };
      };
      initLua = ./init.lua;
      settings = {
        plugin.prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
            group = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
            group = "git";
          }

          {
            id = "mactag";
            url = "*/";
            run = "mactag";
            group = "mactag";
          }
          {
            id = "mactag";
            url = "*";
            run = "mactag";
            group = "mactag";
          }
        ];

        mgr = {
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          sort_dir_first = true;
          linemode = "mtime";
          show_hidden = true;
          show_symlink = true;
          layout = [
            1
            4
            3
          ];
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
        flavor = {
          dark = "catppuccin-mocha";
        };

        tasks = {
          micro_workers = 5;
          macro_workers = 10;
          bizarre_retry = 5;
        };
      };

      plugins = {
        inherit (pkgs.yaziPlugins) git;
        inherit (pkgs.yaziPlugins) mactag;
        inherit (pkgs.yaziPlugins) starship;
        inherit (pkgs.yaziPlugins) smart-paste;
        inherit (pkgs.yaziPlugins) yatline;
        inherit (pkgs.yaziPlugins) yatline-catppuccin;
      };
      flavors = {
        catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = "p";
            run = "plugin smart-paste";
            desc = "Smart paste from clipboard";
          }
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
            on = [
              "c"
              "h"
            ];
            run = "plugin chmod";
            desc = "Chmod on selected files";
          }
          {
            on = [
              "g"
              "i"
            ];
            run = "cd '~/Library/Mobile Documents/com~apple~CloudDocs'";
            desc = "Go to iCloud";
          }
          {
            on = [
              "g"
              "D"
            ];
            run = "cd '~/Projects'";
            desc = "Go to Projects";
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
  };
}
