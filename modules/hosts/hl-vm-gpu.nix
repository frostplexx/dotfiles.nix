{inputs, ...}: {
    flake.modules.nixos.hl-vm-gpu = {
        pkgs,
        lib,
        config,
        defaults,
        modulesPath,
        ...
    }: let
        inherit (defaults) user;
    in {
        imports = [
            (modulesPath + "/installer/scan/not-detected.nix")
            inputs.disko.nixosModules.disko
        ];

        system.stateVersion = "25.11";

        # Boot configuration
        boot = {
            loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
            };
            initrd.availableKernelModules = [
                "nvme"
                "xhci_pci"
                "ahci"
                "usb_storage"
                "usbhid"
                "sd_mod"
                "nvidia"
                "nvidia_modeset"
                "nvidia_uvm"
                "nvidia_drm"
            ];
            initrd.kernelModules = [];
            kernelPackages = pkgs.linuxPackages_zen;
            kernelModules = ["kvm-amd"];
            extraModulePackages = [];
            kernelParams = [
                "acpi_enforce_resources=lax"
                "amd_iommu=on"
                "kvm.enable_virt_at_load=0"
                "iommu=pt"
                "zswap.enabled=1"
                "default_hugepagesz=2M"
                "hugepagesz=2M"
                "hugepages=1024"
                "transparent_hugepage=always"
                "nvidia-drm.modeset=1"
            ];
        };

        disko.devices = {
            disk = {
                main = {
                    type = "disk";
                    device = "/dev/nvme0n1";
                    content = {
                        type = "gpt";
                        partitions = {
                            ESP = {
                                priority = 1;
                                name = "ESP";
                                start = "1M";
                                end = "512M";
                                type = "EF00";
                                content = {
                                    type = "filesystem";
                                    format = "vfat";
                                    mountpoint = "/boot";
                                    mountOptions = ["umask=0077"];
                                };
                            };
                            swap = {
                                size = "35G";
                                type = "8200";
                                content = {
                                    type = "swap";
                                };
                            };
                            root = {
                                size = "100%";
                                content = {
                                    type = "btrfs";
                                    extraArgs = ["-f"];
                                    subvolumes = {
                                        "/rootfs" = {
                                            mountpoint = "/";
                                        };
                                        "/home" = {
                                            mountOptions = ["compress=zstd"];
                                            mountpoint = "/home";
                                        };
                                        "/nix" = {
                                            mountOptions = [
                                                "compress=zstd"
                                                "noatime"
                                            ];
                                            mountpoint = "/nix";
                                        };
                                        "/persist" = {
                                            mountpoint = "/persist";
                                        };
                                    };
                                    mountpoint = "/partition-root";
                                };
                            };
                        };
                    };
                };
            };
        };

        # Let disko handle fileSystems
        # Manual fileSystems disabled - handled by disko
        # fileSystems = lib.mkForce {};
        # swapDevices = lib.mkForce [];

        # Networking
        networking = {
            hostName = "pc-nixos";
            networkmanager.enable = true;
            useDHCP = lib.mkDefault true;
            interfaces."enp4s0".wakeOnLan.enable = true;
        };

        nixpkgs = {
            hostPlatform = lib.mkDefault "x86_64-linux";
            buildPlatform = lib.mkDefault "x86_64-linux";
        };

        # Nix settings
        nix = {
            channel.enable = false;
            extraOptions = ''
                experimental-features = nix-command flakes
                warn-dirty = false
            '';
            nixPath = ["nixpkgs=${inputs.nixpkgs}"];
            settings = {
                extra-platforms = ["aarch64-darwin"];
                extra-trusted-users = [user];
                trusted-users = [
                    "root"
                    user
                ];
                max-jobs = 8;
                sandbox = true;
                substituters = [
                    "https://cache.nixos.org/"
                    "https://nix-community.cachix.org"
                    "https://ojsef39.cachix.org"
                ];
                trusted-public-keys = [
                    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                    "ojsef39.cachix.org-1:Pe8zOhPVMt4fa/2HYlquHkTnGX3EH7lC9xMyCA2zM3Y="
                ];
            };
        };

        # Time and locale
        time.timeZone = defaults.system.timeZone;
        i18n.defaultLocale = defaults.system.locale;
        i18n.extraLocaleSettings = {
            LC_ADDRESS = "de_DE.UTF-8";
            LC_IDENTIFICATION = "de_DE.UTF-8";
            LC_MEASUREMENT = "de_DE.UTF-8";
            LC_MONETARY = "de_DE.UTF-8";
            LC_NAME = "de_DE.UTF-8";
            LC_NUMERIC = "de_DE.UTF-8";
            LC_PAPER = "de_DE.UTF-8";
            LC_TELEPHONE = "de_DE.UTF-8";
            LC_TIME = "de_DE.UTF-8";
        };

        # Power management
        powerManagement = {
            enable = true;
            cpuFreqGovernor = "performance";
        };

        environment.pathsToLink = ["/libexec"];

        # Services
        services = {
            gvfs.enable = true;
            xserver = {
                enable = true;
                videoDrivers = ["nvidia"];
                xkb = {
                    layout = "us";
                    variant = "";
                };
            };
            libinput = {
                enable = true;
                mouse = {
                    accelProfile = "flat";
                    accelSpeed = "0";
                    middleEmulation = false;
                };
            };
            displayManager = {
                sddm.enable = true;
                autoLogin = {
                    enable = true;
                    inherit user;
                };
            };
            desktopManager.plasma6.enable = true;
            openssh.enable = true;
            getty = {
                autologinUser = user;
                extraArgs = ["--noclear"];
            };
            pipewire = {
                enable = true;
                alsa = {
                    enable = true;
                    # 32-bit support disabled due to nixpkgs-unstable issue
                    # support32Bit = true;
                };
                pulse.enable = true;
            };
            printing.enable = true;
            sunshine = {
                enable = true;
                autoStart = true;
                capSysAdmin = true;
                openFirewall = true;
            };
        };

        # TTY2 auto-login
        systemd.services."getty@tty2" = {
            overrideStrategy = "asDropin";
            serviceConfig = {
                ExecStart = [
                    ""
                    "${pkgs.util-linux}/bin/agetty --autologin ${user} --noclear %i $TERM"
                ];
                Type = "idle";
                Restart = "always";
                RestartSec = "5";
            };
            after = ["graphical-session.target"];
            wants = ["graphical-session.target"];
        };

        # Looking Glass
        systemd.tmpfiles.rules = [
            "f /dev/shm/looking-glass 0660 ${user} kvm -"
        ];

        # User configuration
        programs.fish.enable = true;
        users = {
            defaultUserShell = pkgs.fish;
            users.${user} = {
                isNormalUser = true;
                description = defaults.personalInfo.name;
                extraGroups = [
                    "networkmanager"
                    "wheel"
                    "vboxusers"
                    "libvirtd"
                    "kvm"
                ];
            };
        };

        # Hardware
        hardware = {
            cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
            xone.enable = true;
            graphics = {
                enable = true;
                # 32-bit support disabled due to nixpkgs-unstable issue
                # enable32Bit = true;
            };
            bluetooth = {
                enable = true;
                powerOnBoot = true;
            };
            nvidia = {
                modesetting.enable = true;
                powerManagement.enable = true;
                open = false;
                nvidiaSettings = true;
                package = config.boot.kernelPackages.nvidiaPackages.latest;
            };
        };

        # Programs
        programs = {
            # nh = {
            #     enable = true;
            #     clean.enable = true;
            #     clean.extraArgs = "--keep-since 4d --keep 3";
            #     flake = "/home/${user}/${defaults.paths.flake}/";
            # };
            # Gamescope and Steam disabled temporarily due to 32-bit support issues in nixpkgs-unstable
            # gamescope = {
            #     enable = true;
            #     capSysNice = true;
            # };
            # steam = {
            #     enable = true;
            #     remotePlay.openFirewall = true;
            #     dedicatedServer.openFirewall = true;
            #     localNetworkGameTransfers.openFirewall = true;
            # };
            # _1password-gui = {
            #     enable = true;
            #     polkitPolicyOwners = [user];
            # };
            # thunar = {
            #     enable = true;
            #     plugins = with pkgs.xfce; [
            #         thunar-archive-plugin
            #         thunar-volman
            #     ];
            # };
        };

        # Environment
        environment = {
            systemPackages = with pkgs; [
                # looking-glass-client
                # steam
                # steam-run
                # lutris
                # gamemode
                # gamescope
                # kbd
                # mangohud
                # prismlauncher
                # solaar
                # linuxKernel.packages.linux_zen.xone
                # ckan
                # openrgb-with-all-plugins
                # _1password-gui
                # papirus-icon-theme
                # simplescreenrecorder
                # kdePackages.filelight
                # vlc
                # xclip
                # cifs-utils
                # xorg.xrandr
                # xorg.xinput
                # picom
                # xfce.thunar
                # xfce.tumbler
                # xfce.thunar-archive-plugin
                # xfce.thunar-volman
                # ffmpegthumbnailer
                # gvfs
                # flameshot
                # polkit
                # catppuccin-gtk
                # catppuccin-cursors
                # feh
                # networkmanager
                # imlib2
                # libsecret
            ];
            variables = {
                FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
                QT_ENABLE_HIGHDPI_SCALING = "1";
                QT_AUTO_SCREEN_SCALE_FACTOR = "0.9";
            };
        };

        # Documentation
        documentation = {
            enable = true;
            man = {
                enable = true;
                generateCaches = true;
            };
            dev.enable = true;
        };

        # Home Manager
        home-manager.users.${user} = _: {
            home = {
                stateVersion = "23.11";
                username = user;
                homeDirectory = "/home/${user}";
                sessionVariables = {
                    NH_FLAKE = "$HOME/${defaults.paths.flake}";
                    EDITOR = "nvim";
                };
            };
            programs.home-manager.enable = true;
        };
    };
}

