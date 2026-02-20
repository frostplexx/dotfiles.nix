_: {
    flake.modules.homeManager.hyprland = {
        inputs,
        pkgs,
        lib,
        ...
    }: let
        accent_color = "cba6f7";
    in {
        xdg.configFile = lib.mkIf pkgs.stdenv.isLinux {
            # Copy the filtered nvim configuration directory
            "hypr" = {
                source = ./hyprland/hypr;
                recursive = true;
            };
        };

        programs = lib.mkIf pkgs.stdenv.isLinux {
            caelestia = {
                enable = true;
                package = inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
                    material-symbols = pkgs.material-symbols;
                };
                systemd = {
                    enable = true; # if you prefer starting from your compositor
                    target = "graphical-session.target";
                    environment = [];
                };
                settings = {
                    general = {
                        apps = {
                            terminal = ["kitty"];
                            audio = ["pavucontrol"];
                            playback = ["mpv"];
                            explorer = ["nemo"];
                        };
                    };
                    bar = {
                      clock.showIcon = false;
                      status = {
                          showBattery = false;
                          showAudio = true;
                          showWifi = false;
                      };
                    };

                    appearance = {
                      transparency.enabled = false;
                   };
                    sidebar = {
                        enabled = true;
                    };
                    osd = {
                        enableMicrophone = true;
                    };
                    launcher = {
                        enableDangerousActions = true;
                        vimKeybinds = true;
                        useFuzzy = {
                          apps = true;
                        };
                        favouriteApps = [
                        "steam"
                        "kitty"
                        "discord"
                        ];
                    };
                    notifs = {
                        actionOnClick = true;
                    };
                    paths.wallpaperDir = "/home/daniel/Pictures/Wallpapers";
                    services = {
                        maxVolume = 2.0;
                        defaultPlayer = "tidal-hifi";
                        useTwelveHourClock = false;
                        useFahrenheit = false;
                    };
                    utilities = {
                        # vpn = {
                        #     enabled = false;
                        #     provider = [
                        #         {
                        #             name = "T";
                        #             interface = "T";
                        #             displayName = "T";
                        #             connectCmd = ["${pkgs.networkmanager}/bin/nmcli" "connection" "up" "T"];
                        #             disconnectCmd = ["${pkgs.networkmanager}/bin/nmcli" "connection" "down" "T"];
                        #         }
                        #     ];
                        # };
                    };
                };
                cli = {
                    enable = true; # Also add caelestia-cli to path
                    settings = {
                        theme.enableGtk = true;
                    };
                };
            };
            # waybar.enable = true;
        };

        # services.swaync = lib.mkIf pkgs.stdenv.isLinux {
        #   enable = true;
        # };

        wayland.windowManager.hyprland = lib.mkIf pkgs.stdenv.isLinux {
            # Whether to enable Hyprland wayland compositor
            enable = true;
            # The hyprland package to use
            package = pkgs.hyprland;
            # Whether to enable XWayland
            xwayland.enable = true;

            portalPackage =
                inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

            # Optional
            # Whether to enable hyprland-session.target on hyprland startup
            systemd.enable = true;
        };
    };
}
