{pkgs, ...}: let
    yazi-plugins = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "7c174cc0ae1e07876218868e5e0917308201c081";
        hash = "sha256-RE93ZNlG6CRGZz7YByXtO0mifduh6MMGls6J9IYwaFA=";
    };

    yazi-flavors = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "d04a298a8d4ada755816cb1a8cfb74dd46ef7124";
        hash = "sha256-m3yk6OcJ9vbCwtxkMRVUDhMMTOwaBFlqWDxGqX2Kyvc=";
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
        };

        plugins = {
            chmod = "${yazi-plugins}/chmod.yazi";
            smart-filter = "${yazi-plugins}/smart-filter.yazi";
            vcs-files = "${yazi-plugins}/vcs-files.yazi";
        };
        flavors = {
            catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
        };

        initLua = ''
        '';

        keymap = {
            mgr.prepend_keymap = [
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
