{pkgs, ...}: let
    yazi-plugins = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "plugins";
        rev = "e5f00e2716fd177b0ca0d313f1a6e64f01c12760";
        hash = "sha256-DLcmzCmITybWrYuBpTyswtoGUimpagkyeVUWmbKjarY=";
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
        };

        plugins = {
            chmod = "${yazi-plugins}/chmod.yazi";
            smart-filter = "${yazi-plugins}/smart-filter.yazi";
            vcs-files = "${yazi-plugins}/vcs-files.yazi";
            easyjump = pkgs.fetchFromGitHub {
                owner = "DreamMaoMao";
                repo = "easyjump.yazi";
                rev = "6606fb1d56eea4c99809c056fd701e58890655be";
                hash = "sha256-YKuznrwA7aT1lNP5F2+PnvyvMyBScd9kotrhA32th3M=";
            };
            starship = pkgs.fetchFromGitHub {
                owner = "Rolv-Apneseth";
                repo = "starship.yazi";
                rev = "6a0f3f788971b155cbc7cec47f6f11aebbc148c9";
                hash = "sha256-q1G0Y4JAuAv8+zckImzbRvozVn489qiYVGFQbdCxC98=";
            };
        };
        flavors = {
            catppuccin-mocha = "${yazi-flavors}/catppuccin-mocha.yazi";
        };

        initLua = ''
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
                    on = "i";
                    run = "plugin easyjump";
                    desc = "easyjump";
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
