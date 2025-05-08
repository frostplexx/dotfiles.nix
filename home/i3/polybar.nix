# Polybar configuration for NixOS with Catppuccin theme
{
    config,
    pkgs,
    ...
}: {
    services.polybar = {
        enable = true;
        package = pkgs.polybar.override {
            i3Support = true;
            pulseSupport = true;
        };
        script = "polybar main &";
        config = {
            "global/wm" = {
                margin-top = 0;
                margin-bottom = 0;
            };

            "colors" = {
                # Catppuccin Mocha palette
                base = "#1e1e2e";
                mantle = "#181825";
                surface0 = "#313244";
                surface1 = "#45475a";
                surface2 = "#585b70";
                overlay0 = "#6c7086";
                overlay1 = "#7f849c";
                overlay2 = "#9399b2";
                text = "#cdd6f4";
                subtext0 = "#a6adc8";
                subtext1 = "#bac2de";
                blue = "#89b4fa";
                lavender = "#b4befe";
                sapphire = "#74c7ec";
                sky = "#89dceb";
                teal = "#94e2d5";
                green = "#a6e3a1";
                yellow = "#f9e2af";
                peach = "#fab387";
                maroon = "#eba0ac";
                red = "#f38ba8";
                mauve = "#cba6f7";
                pink = "#f5c2e7";
                flamingo = "#f2cdcd";
                rosewater = "#f5e0dc";
                transparent = "#FF00000";
            };

            "bar/main" = {
                width = "100%";
                height = 32;
                radius = 0;
                fixed-center = true;

                background = "\${colors.base}";
                foreground = "\${colors.text}";

                line-size = 3;
                line-color = "\${colors.blue}";

                border-size = 0;
                border-color = "\${colors.mantle}";

                padding-left = 2;
                padding-right = 2;

                module-margin-left = 1;
                module-margin-right = 1;

                font-0 = "Maple Mono:style=Medium:size=10;2";
                font-1 = "Maple Mono:style=Bold:size=10;2";
                font-2 = "Maple Mono:size=19;5";
                font-3 = "Maple Mono:size=13;4";

                modules-left = "i3 xwindow";
                modules-center = "date";
                modules-right = "pulseaudio memory cpu temperature battery network";

                tray-position = "right";
                tray-padding = 2;
                tray-background = "\${colors.base}";

                cursor-click = "pointer";
                cursor-scroll = "ns-resize";
            };

            "module/i3" = {
                type = "internal/i3";
                format = "<label-state> <label-mode>";
                index-sort = true;
                wrapping-scroll = false;

                label-mode-padding = 2;
                label-mode-foreground = "\${colors.base}";
                label-mode-background = "\${colors.yellow}";

                label-focused = "%index%";
                label-focused-background = "\${colors.surface0}";
                label-focused-underline = "\${colors.blue}";
                label-focused-padding = 2;

                label-unfocused = "%index%";
                label-unfocused-padding = 2;

                label-visible = "%index%";
                label-visible-background = "\${self.label-focused-background}";
                label-visible-underline = "\${self.label-focused-underline}";
                label-visible-padding = "\${self.label-focused-padding}";

                label-urgent = "%index%";
                label-urgent-background = "\${colors.red}";
                label-urgent-padding = 2;
            };

            "module/xwindow" = {
                type = "internal/xwindow";
                label = "%title:0:60:...%";
                label-foreground = "\${colors.text}";
            };

            "module/cpu" = {
                type = "internal/cpu";
                interval = 2;
                format-prefix = " ";
                format-prefix-foreground = "\${colors.red}";
                label = "%percentage:2%%";
            };

            "module/memory" = {
                type = "internal/memory";
                interval = 2;
                format-prefix = " ";
                format-prefix-foreground = "\${colors.yellow}";
                label = "%percentage_used%%";
            };

            "module/date" = {
                type = "internal/date";
                interval = 5;

                date = " %Y-%m-%d";
                date-alt = " %Y-%m-%d";

                time = "%H:%M";
                time-alt = "%H:%M:%S";

                format-prefix = "";
                format-prefix-foreground = "\${colors.blue}";

                label = "%date% %time%";
            };

            "module/pulseaudio" = {
                type = "internal/pulseaudio";

                format-volume = "<ramp-volume> <label-volume>";
                label-volume = "%percentage%%";
                label-volume-foreground = "\${colors.text}";

                format-muted-prefix = " ";
                format-muted-foreground = "\${colors.overlay0}";
                label-muted = "muted";

                ramp-volume-0 = "";
                ramp-volume-1 = "";
                ramp-volume-2 = "";
                ramp-volume-foreground = "\${colors.mauve}";

                click-right = "pavucontrol";
            };

            "module/temperature" = {
                type = "internal/temperature";
                thermal-zone = 0;
                warn-temperature = 70;

                format = "<ramp> <label>";
                format-warn = "<ramp> <label-warn>";
                format-warn-underline = "\${colors.red}";

                label = "%temperature-c%";
                label-warn = "%temperature-c%";
                label-warn-foreground = "\${colors.red}";

                ramp-0 = "";
                ramp-1 = "";
                ramp-2 = "";
                ramp-foreground = "\${colors.teal}";
            };

            "module/battery" = {
                type = "internal/battery";
                battery = "BAT0";
                adapter = "AC";
                full-at = 98;

                format-charging = "<animation-charging> <label-charging>";
                format-charging-underline = "\${colors.yellow}";

                format-discharging = "<ramp-capacity> <label-discharging>";
                format-discharging-underline = "\${colors.yellow}";

                format-full-prefix = " ";
                format-full-prefix-foreground = "\${colors.green}";
                format-full-underline = "\${colors.green}";

                ramp-capacity-0 = "";
                ramp-capacity-1 = "";
                ramp-capacity-2 = "";
                ramp-capacity-foreground = "\${colors.yellow}";

                animation-charging-0 = "";
                animation-charging-1 = "";
                animation-charging-2 = "";
                animation-charging-foreground = "\${colors.green}";
                animation-charging-framerate = 750;
            };

            "module/network" = {
                type = "internal/network";
                interface = "eth0"; # Change this to your network interface
                interval = "3.0";

                format-connected = "<ramp-signal> <label-connected>";
                format-connected-underline = "\${colors.sapphire}";
                label-connected = "%essid%";

                format-disconnected = "<label-disconnected>";
                format-disconnected-underline = "\${colors.red}";
                label-disconnected = "disconnected";
                label-disconnected-foreground = "\${colors.overlay0}";

                ramp-signal-0 = "";
                ramp-signal-1 = "";
                ramp-signal-2 = "";
                ramp-signal-3 = "";
                ramp-signal-4 = "";
                ramp-signal-foreground = "\${colors.sapphire}";
            };

            "settings" = {
                screenchange-reload = true;
            };
        };
    };
}
