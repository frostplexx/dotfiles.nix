{
    pkgs,
    assets,
    config,
    ...
}: {
    imports = [./dunst.nix ./picom.nix ./rofi.nix];

    # Enable X11 and i3
    xsession.windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        config = {
            modifier = "Mod4"; # Windows/Super key
            gaps = {
                inner = 5;
                outer = 2;
            };

            # Set monitor refresh rate to 144Hz and disable mouse acceleration
            startup = [
                {
                    command = "xrandr --output DP-2 --mode 2560x1080 --rate 144";
                    always = true;
                    notification = false;
                }
                {
                    # Disable mouse acceleration
                    command = "xinput --set-prop 'Logitech USB Receiver' 'libinput Accel Profile Enabled' 0, 1";
                    always = true;
                    notification = false;
                }
                {
                    command = "${pkgs.feh}/bin/feh --bg-fill ${assets}/wallpapers/wallpaper.png";
                    always = true;
                    notification = false;
                }
                {
                    # Set flat acceleration (1.0 = no acceleration)
                    command = "xinput --set-prop 'Logitech USB Receiver' 'libinput Accel Speed' 0";
                    always = true;
                    notification = false;
                }
                {
                    # Set default workspace to 1 when starting i3
                    command = "i3-msg workspace number 1";
                    always = true;
                    notification = false;
                }
                {
                    # Start 1password in the background
                    command = "1password --silent";
                    always = true;
                    notification = false;
                }
            ];

            # Keybindings ported from AeroSpace
            keybindings = let
                modifier = "Mod4";
                alt = "Mod1";
                ctrl = "Control";
                shift = "Shift";
            in {
                # Application control (Cmd+Q to quit)
                "${modifier}+q" = "kill";
                "${modifier}+space" = "exec rofi -show run";
                "${modifier}+${shift}+4" = "exec flameshot gui";

                "${modifier}+Tab" = "exec rofi -show window";

                # Layout controls
                "${ctrl}+${alt}+${modifier}+t" = "layout toggle split";
                "${ctrl}+${alt}+${modifier}+s" = "layout stacking";

                # Fullscreen and floating toggle
                "${ctrl}+${alt}+${modifier}+Space" = "fullscreen toggle";
                "${ctrl}+${alt}+${modifier}+f" = "floating toggle";

                "${ctrl}+${alt}+${modifier}+Enter" = "exec kitty";

                # Window focus
                "${ctrl}+${alt}+${modifier}+h" = "focus left";
                "${ctrl}+${alt}+${modifier}+j" = "focus down";
                "${ctrl}+${alt}+${modifier}+k" = "focus up";
                "${ctrl}+${alt}+${modifier}+l" = "focus right";

                # Window resize
                "${ctrl}+${alt}+${shift}+${modifier}+minus" = "resize shrink width 50 px or 50 ppt";
                "${ctrl}+${alt}+${shift}+${modifier}+equal" = "resize grow width 50 px or 50 ppt";

                # Workspace switching
                "${ctrl}+${alt}+${modifier}+1" = "workspace number 1";
                "${ctrl}+${alt}+${modifier}+2" = "workspace number 2";
                "${ctrl}+${alt}+${modifier}+3" = "workspace number 3";
                "${ctrl}+${alt}+${modifier}+4" = "workspace number 4";
                "${ctrl}+${alt}+${modifier}+5" = "workspace number 5";
                "${ctrl}+${alt}+${modifier}+6" = "workspace number 6";
                "${ctrl}+${alt}+${modifier}+7" = "workspace number 7";
                "${ctrl}+${alt}+${modifier}+8" = "workspace number 8";
                "${ctrl}+${alt}+${modifier}+9" = "workspace number 9";
                "${ctrl}+${alt}+${modifier}+0" = "workspace number 10";

                # Move windows to workspaces
                "${ctrl}+${alt}+${shift}+${modifier}+1" = "move container to workspace number 1; workspace number 1";
                "${ctrl}+${alt}+${shift}+${modifier}+2" = "move container to workspace number 2; workspace number 2";
                "${ctrl}+${alt}+${shift}+${modifier}+3" = "move container to workspace number 3; workspace number 3";
                "${ctrl}+${alt}+${shift}+${modifier}+4" = "move container to workspace number 4; workspace number 4";
                "${ctrl}+${alt}+${shift}+${modifier}+5" = "move container to workspace number 5; workspace number 5";
                "${ctrl}+${alt}+${shift}+${modifier}+6" = "move container to workspace number 6; workspace number 6";
                "${ctrl}+${alt}+${shift}+${modifier}+7" = "move container to workspace number 7; workspace number 7";
                "${ctrl}+${alt}+${shift}+${modifier}+8" = "move container to workspace number 8; workspace number 8";
                "${ctrl}+${alt}+${shift}+${modifier}+9" = "move container to workspace number 9; workspace number 9";

                # Move windows
                "${ctrl}+${alt}+${shift}+${modifier}+h" = "move left";
                "${ctrl}+${alt}+${shift}+${modifier}+j" = "move down";
                "${ctrl}+${alt}+${shift}+${modifier}+k" = "move up";
                "${ctrl}+${alt}+${shift}+${modifier}+l" = "move right";

                # Join/move window to another (using focus parent + move)
                "${alt}+${shift}+h" = "focus parent; split h; focus right; move left";
                "${alt}+${shift}+j" = "focus parent; split v; focus down; move up";
                "${alt}+${shift}+k" = "focus parent; split v; focus up; move down";
                "${alt}+${shift}+l" = "focus parent; split h; focus left; move right";

                # Back and forth (similar to alt-tab)
                "${alt}+Tab" = "workspace back_and_forth";
                "${alt}+${shift}+Tab" = "move container to output next; focus output next";

                # Reload config
                "${ctrl}+${alt}+${modifier}+semicolon" = "exec i3-msg reload";
            };

            # Window assignments similar to your AeroSpace config
            assigns = {
                "1" = [
                    {class = "^firefox$";}
                    {class = "^Zen$";}
                ];
                "2" = [
                    {class = "^jetbrains-idea$";}
                    {class = "^WezTerm$";}
                    {class = "^Termius$";}
                    {class = "^kitty$";}
                ];
                "3" = [
                    {class = "^GoodNotes$";}
                    {class = "^obsidian$";}
                    {class = "^[sS]team$";}
                ];
                "4" = [
                    {class = "^vesktop$";}
                    {class = "^zoom$";}
                    {class = "^Discord$";}
                ];
                "5" = [
                    {class = "^Spotify$";}
                ];
            };

            # Floating windows
            floating = {
                criteria = [
                    {class = "^Finder$";}
                    {class = "^1Password$";}
                    {class = "^CleanShotX$";}
                    {title = "^kittyfloat$";}
                    {title = "^Picture-in-Picture$";}
                ];
            };

            # Colors based on your jankyborders theme
            colors = {
                focused = {
                    border = "#cba6f7";
                    background = "#cba6f7";
                    text = "#ffffff";
                    indicator = "#cba6f7";
                    childBorder = "#cba6f7";
                };
                unfocused = {
                    border = "#7f849c";
                    background = "#7f849c";
                    text = "#ffffff";
                    indicator = "#7f849c";
                    childBorder = "#7f849c";
                };
            };

            # Border styling (similar to your jankyborders configuration)
            window.border = 2;
            window.titlebar = false;

            bars = [
                {
                    position = "bottom";
                    statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
                    fonts = {
                        names = ["Maple Mono NF"];
                        size = 10.0;
                    };
                    hiddenState = "hide";
                    mode = "dock";
                    trayOutput = "primary";

                    colors = {
                        # Catppuccin Mocha colors
                        background = "#1e1e2e";
                        statusline = "#cdd6f4";
                        separator = "#585b70";

                        # Workspace colors
                        focusedWorkspace = {
                            border = "#cba6f7";
                            background = "#1e1e2e";
                            text = "#cdd6f4";
                        };
                        activeWorkspace = {
                            border = "#45475a";
                            background = "#1e1e2e";
                            text = "#cdd6f4";
                        };
                        inactiveWorkspace = {
                            border = "#181825";
                            background = "#1e1e2e";
                            text = "#a6adc8";
                        };
                        urgentWorkspace = {
                            border = "#f38ba8";
                            background = "#1e1e2e";
                            text = "#cdd6f4";
                        };
                        bindingMode = {
                            border = "#f9e2af";
                            background = "#1e1e2e";
                            text = "#11111b";
                        };
                    };
                }
            ];
        };
    };

    home.file = {
        ".background-image" = {
            source = "${assets}/wallpapers/wallpaper.png";
        };
    };

    xdg.configFile = {
        "gtk-4.0/assets".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/assets";
        "gtk-4.0/gtk.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk.css";
        "gtk-4.0/gtk-dark.css".source = "${config.gtk.theme.package}/share/themes/${config.gtk.theme.name}/gtk-4.0/gtk-dark.css";
    };

    gtk = {
        enable = true;
        theme = {
            name = "Catppuccin-Mocha-Standard-Mauve-Dark";
            package = pkgs.catppuccin-gtk.override {
                accents = ["mauve"];
                variant = "mocha";
            };
        };
        iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
        };
        font = {
            name = "Inter";
            size = 11;
        };
        gtk3.extraConfig = {
            gtk-application-prefer-dark-theme = true;
        };
        gtk4.extraConfig = {
            gtk-application-prefer-dark-theme = true;
        };
    };

    # Cursor theme to match your overall aesthetic
    home.pointerCursor = {
        name = "Catppuccin-Mocha-Mauve-Cursors";
        package = pkgs.catppuccin-cursors.mochaMauve;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
    };
}
