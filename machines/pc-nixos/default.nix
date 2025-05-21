# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ../shared.nix
        ./apps.nix
        ./sunshine.nix
    ];

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "pc-nixos"; # Define your hostname.

    # Enable networking
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Rome";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
        LC_ADDRESS = "it_IT.UTF-8";
        LC_IDENTIFICATION = "it_IT.UTF-8";
        LC_MEASUREMENT = "it_IT.UTF-8";
        LC_MONETARY = "it_IT.UTF-8";
        LC_NAME = "it_IT.UTF-8";
        LC_NUMERIC = "it_IT.UTF-8";
        LC_PAPER = "it_IT.UTF-8";
        LC_TELEPHONE = "it_IT.UTF-8";
        LC_TIME = "it_IT.UTF-8";
    };

    powerManagement = {
        enable = true;
        cpuFreqGovernor = "perfomance";
    };

    environment.pathsToLink = ["/libexec"];
    virtualisation.virtualbox = {
        host = {
            enable = true;
            enableExtensionPack = true;
            # enableKvm = true;
        };
        guest = {
            enable = true;
            dragAndDrop = true;
        };
    };

    services = {
        keyd = {
            enable = true;
            keyboards = {
                default = {
                    ids = ["*"];
                    settings = {
                        main = {
                            capslock = "overload(capslock_layer, esc)";
                        };
                        "capslock_layer:C-A-M" = {
                        };
                    };
                };
            };
        };

        # For git secrets and shit
        # gnome.gnome-keyring.enable = true;

        xserver = {
            enable = true;

            # Configure mouse settings to disable acceleration
            libinput = {
                enable = true;
                mouse = {
                    accelProfile = "flat";
                    accelSpeed = "0";
                    middleEmulation = false;
                };
            };

            displayManager = {
                defaultSession = "none+i3";
                # defaultSession = "cinnamon";
                autoLogin.user = "daniel";

                sessionCommands = ''
                    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
                    Xft.autohint: 0
                    Xft.antialias: 1
                    Xft.hinting: true
                    Xft.hintstyle: hintslight
                    Xft.dpi: 96
                    Xft.rgba: rgb
                    Xft.lcdfilter: lcddefault
                    EOF
                '';
            };
            windowManager.i3.enable = true;
            # desktopManager.cinnamon = {
            #     enable = true;
            # };
            videoDrivers = ["nvidia"];
            xkb = {
                layout = "us";
                variant = "";
            };
        };
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    programs.fish.enable = true;
    users = {
        defaultUserShell = pkgs.fish;
        users = {
            daniel = {
                isNormalUser = true;
                description = "Daniel";
                extraGroups = ["networkmanager" "wheel" "vboxusers"];
            };
        };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment = {
        variables = {
            FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
            QT_ENABLE_HIGHDPI_SCALING = "1";
            QT_AUTO_SCREEN_SCALE_FACTOR = "0.9";
        };
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:
    services = {
        # Enable the OpenSSH daemon.
        openssh.enable = true;
        # Enable automatic login for the user.
        # getty.autologinUser = "daniel";

        # Audio
        pipewire = {
            enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
            pulse.enable = true;
        };

        # Other services
        printing.enable = true;
    };

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
}
