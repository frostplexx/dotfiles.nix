{pkgs, ...}: let
    yazi-flavors = pkgs.fetchFromGitHub {
        owner = "yazi-rs";
        repo = "flavors";
        rev = "4a1802a5add0f867b08d5890780c10dd1f051c36";
        hash = "sha256-RrF97Lg9v0LV+XseJw4RrdbXlv+LJzfooOgqHD+LGcw=";
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
            starship = pkgs.fetchFromGitHub {
                owner = "Rolv-Apneseth";
                repo = "starship.yazi";
                rev = "eca186171c5f2011ce62712f95f699308251c749";
                hash = "sha256-xcz2+zepICZ3ji0Hm0SSUBSaEpabWUrIdG7JmxUl/ts=";
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
