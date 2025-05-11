{pkgs, ...}: {
    programs.rofi = {
        enable = true;
        plugins = [
            pkgs.rofi-calc
        ];
        theme = "spotlight-theme";
        terminal = "${pkgs.kitty}/bin/kitty";
        extraConfig = {
            modi = "drun,run,calc";
            show-icons = true;
            display-drun = "Applications";
            drun-display-format = "{name}";
            disable-history = false;
            hide-scrollbar = true;
        };
    };
    xdg.configFile = {
        "rofi/catppuccin-mocha.rasi".source = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/rofi/refs/heads/main/themes/catppuccin-mocha.rasi";
            sha256 = "0mdg3kmszkdr50n4c69p6xkf7ilh57h39hp4nwbfzyfm6wn89rza";
        };
        "rofi/catppuccin-default.rasi".source = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/rofi/refs/heads/main/catppuccin-default.rasi";
            sha256 = "1lwzc71cdb7nd0qmmdnnkr512rdj6xk62mx260m049wi1vlg5pdv";
        };
        "rofi/spotlight-theme.rasi".text = ''
            * {
                background-color:      rgba(30, 30, 46, 80%);
                text-color:            rgba(205, 214, 244, 100%);
                font:                  "Maple Mono NF 12";
                border-color:          rgba(137, 180, 250, 100%);
            }

            window {
                location:              center;
                width:                 40%;
                y-offset:              -10%;
                border-radius:         12px;
                background-color:      @background-color;
            }

            mainbox {
                padding:               12px;
            }

            inputbar {
                background-color:      transparent;
                border:                0 0 0 0;
                padding:               0px 0px 12px 0px;
            }

            prompt {
                padding:               6px 10px;
                background-color:      transparent;
                text-color:            @text-color;
                font:                  inherit;
            }

            entry {
                padding:               6px 10px;
                background-color:      transparent;
                text-color:            inherit;
                font:                  inherit;
            }

            listview {
                lines:                 8;
                columns:               1;
                fixed-height:          false;
                spacing:               4px;
                scrollbar:             false;
                background-color:      transparent;
            }

            element {
                padding:               8px;
                spacing:               4px;
                border-radius:         6px;
            }

            element normal.normal {
                background-color:      transparent;
                text-color:            @text-color;
            }

            element selected.normal {
                background-color:      rgba(137, 180, 250, 30%);
                text-color:            rgba(205, 214, 244, 100%);
            }

            element-text {
                background-color:      transparent;
                text-color:            inherit;
                highlight:             inherit;
            }

            element-icon {
                background-color:      transparent;
                size:                  24px;
            }

            message {
                padding:               4px;
                background-color:      transparent;
            }
        '';
    };
}
