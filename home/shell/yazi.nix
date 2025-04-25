{pkgs, ...}: let
    yazi-plugins = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "4b027c79371af963d4ae3a8b69e42177aa3fa6ee";
        hash = "sha256-auGNSn6tX72go7kYaH16hxRng+iZWw99dKTTUN91Cow=";
    };

    yazi-flavors = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "68326b4ca4b5b66da3d4a4cce3050e5e950aade5";
        hash = "sha256-nhIhCMBqr4VSzesplQRF6Ik55b3Ljae0dN+TYbzQb5s=";
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
                # prepend_fetchers = [
                #   {
                #     id = "git";
                #     name = "*";
                #     run = "git";
                #   }
                #   {
                #     id = "git";
                #     name = "*/";
                #     run = "git";
                #   }
                # ];
            };
        };

        plugins = {
            chmod = "${yazi-plugins}/chmod.yazi";
            full-border = "${yazi-plugins}/full-border.yazi";
            max-preview = "${yazi-plugins}/max-preview.yazi";
            smart-filter = "${yazi-plugins}/smart-filter.yazi";
            # git = "${yazi-plugins}/git.yazi";
            vcs-files = "${yazi-plugins}/vcs-files.yazi";
            starship = pkgs.fetchFromGitHub {
                owner = "Rolv-Apneseth";
                repo = "starship.yazi";
                rev = "6fde3b2d9dc9a12c14588eb85cf4964e619842e6";
                hash = "sha256-+CSdghcIl50z0MXmFwbJ0koIkWIksm3XxYvTAwoRlDY=";
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
            -- require("git"):setup()
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
                    on = ["g" "c"];
                    run = "plugin vcs-files";
                    desc = "Show Git file changes";
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
