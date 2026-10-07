_: {
  flake.nixOSModules.tiramisu = {
    pkgs,
    config,
    defaults,
    ...
  }: let
    inherit (defaults) user;
  in {
    system.stateVersion = defaults.system.nixosVersion;

    # Nix settings (read by Determinate Nixd from /etc/nix/nix.custom.conf)
    nix.settings =
      defaults.nixSettings
      // {
        # CachyOS kernel binary cache
        substituters = defaults.nixSettings.substituters ++ ["https://attic.xuyh0120.win/lantian"];
        trusted-public-keys = defaults.nixSettings.trusted-public-keys ++ ["lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="];
        trusted-users = ["root" user];
      };

    # Networking
    networking = {
      hostName = "tiramisu";
      networkmanager.enable = true;
      nameservers = [
        "94.140.14.49"
        "94.140.14.59"
      ];
    };

    # Wake-on-LAN, matched by MAC since the predictable interface name isn't
    # fixed here. A .link file replaces 99-default.link for this NIC, so the
    # default naming/MAC policies are repeated to keep the usual enp* name.
    # Magic packets are handled by the NIC while the PC is off, so no firewall
    # port is needed.
    systemd.network.links."50-wol" = {
      matchConfig.MACAddress = "74:56:3c:30:fc:b7";
      linkConfig = {
        NamePolicy = "keep kernel database onboard slot path";
        AlternativeNamesPolicy = "database onboard slot path";
        MACAddressPolicy = "persistent";
        WakeOnLan = "magic";
      };
    };

    time.timeZone = defaults.system.timeZone;
    i18n.defaultLocale = defaults.system.locale;

    boot = {
      initrd.systemd.enable = true;
      # Quiet boot; plymouth already adds "splash" and "loglevel=4"
      kernelParams = ["quiet"];
      loader = {
        limine = {
          enable = true;
          maxGenerations = 4;
          style.wallpapers = [
            (builtins.fetchurl {
              name = "windows7-wallpaper.jpg";
              url = "https://static.wikitide.net/windowswallpaperwiki/5/50/Img0_%28Windows_7%29.jpg";
              sha256 = "18h6y8mmf99g5l24gwbpsfmyg1ib47xkdz1wbcd53aknii3giabf";
            })
          ];
        };
        efi.canTouchEfiVariables = true;
      };
      kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-x86_64-v3;
    };

    disko.devices.disk.main = {
      type = "disk";
      device = "/dev/disk/by-id/nvme-eui.0025385111b0876e";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f"];
              subvolumes = {
                "/@" = {
                  mountpoint = "/";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/@home" = {
                  mountpoint = "/home";
                  mountOptions = ["compress=zstd" "noatime"];
                };
                "/@nix" = {
                  mountpoint = "/nix";
                  mountOptions = ["compress=zstd" "noatime"];
                };
              };
            };
          };
        };
      };
    };

    services = {
      glances = {
        # Default port is 61208
        enable = true;
        openFirewall = true;
      };
      xserver.videoDrivers = ["nvidia"];
      desktopManager.plasma6.enable = true;
      # The AeroThemePlasma shell requires SDDM for its login theme
      displayManager = {
        sddm.enable = true;
        defaultSession = "aerothemeplasma";
        # Boot straight into the desktop (gaming PC, also reached via Sunshine)
        autoLogin = {
          enable = true;
          inherit user;
        };
      };
    };

    # AeroThemePlasma: Windows 7 themed Plasma shell
    programs.aeroshell = {
      enable = true;
      fonts = {
        segoe.enable = true;
        # atn's lucida-console package requires a store file with a hash that
        # differs from the URL below, so we install the font directly instead.
        lucida.enable = false;
      };
      polkit.enable = true;
      aerothemeplasma = {
        enable = true;
        sddm.enable = true;
        plymouth.enable = true;
        plymouth.settings = {
          BootSlowdown = 0;
        };
      };
    };

    boot.plymouth.enable = true;

    systemd.user.services.steam = {
      enable = true;
      description = "Open Steam in the background at boot";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${config.programs.steam.package}/bin/steam -nochatui -nofriendsui -silent";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
    hardware = {
      bluetooth.enable = true;
      graphics = {
        enable = true;
      };
      nvidia = {
        modesetting.enable = true;
        nvidiaSettings = true;
        open = true;
      };
    };

    programs = {
      fish.enable = true;
      steam = {
        enable = true;
        extest.enable = true;
        package = pkgs.millennium-steam;
      };
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = [user];
      };
    };

    users.users.${user} = {
      isNormalUser = true;
      description = user;
      # Only used when the user is first created; SSH below is key-only, so
      # this can't be used to log in remotely.
      initialPassword = "changeme";
      shell = pkgs.fish;
      extraGroups = ["wheel" "networkmanager" "video" "audio"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxoqb81bUGp//jr1iYhEMSq7XhzWLtGAJJTu81heOxQ"
      ];
    };

    # Host secrets. The SSH host key doubles as the age decryption key, so
    # nothing needs to be provisioned on the machine.
    sops = {
      age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
      # User passwords are needed before users are created, so this is
      # decrypted early, to /run/secrets-for-users/power-password.
      secrets."power-password" = {
        sopsFile = ./secrets.yaml;
        neededForUsers = true;
      };
    };

    # Password-only SSH account for shutting the PC down remotely; Wake-on-LAN
    # above is the counterpart for waking it back up. No groups, no authorized
    # keys, so its only abilities are logging in with the password and
    # powering off/rebooting via the polkit rule below.
    users.users.power = {
      isNormalUser = true;
      description = "Remote power off";
      hashedPasswordFile = config.sops.secrets."power-password".path;
      shell = pkgs.fish;
    };

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
      # Appended after the settings above, and Match blocks must come last.
      # Password login stays off globally; only the power user may use it.
      extraConfig = ''
        Match User power
          PasswordAuthentication yes
      '';
    };

    # Remote SSH sessions have no seat, so the default polkit policy denies
    # them power-off. Allow the power user exactly that (and reboot), and
    # nobody else.
    security.polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (subject.user == "power" &&
              (action.id == "org.freedesktop.login1.power-off" ||
               action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
               action.id == "org.freedesktop.login1.power-off-ignore-inhibit" ||
               action.id == "org.freedesktop.login1.reboot" ||
               action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
               action.id == "org.freedesktop.login1.reboot-ignore-inhibit")) {
            return polkit.Result.YES;
          }
        });
      '';
    };

    # tiramisu is gaming-only: no system-wide CLI tools. Apps live in
    # home-manager below; jinx brings what it needs to deploy, and `op`
    # comes from programs._1password.
    environment = {
      pathsToLink = ["/share/fish"];
      shells = [pkgs.fish];

      plasma6.excludePackages = with pkgs.kdePackages; [
        plasma-browser-integration
        konsole
        elisa
        qrca
      ];
    };

    fonts.packages = with pkgs; [
      maple-mono.NF
      (stdenvNoCC.mkDerivation {
        pname = "lucida-console";
        version = "1.60";
        src = fetchurl {
          name = "lucon.ttf";
          # Pinned to the commit that fixes the file
          url = "https://raw.githubusercontent.com/famesxd/Lucida-Console/15a149da9bde8c5290a551cde1bdb376f19d10af/lucon.ttf";
          hash = "sha256-bd9k7oltJM+ZCPEVriIKfPoY3ANLxKaOTbaNzVfHFRI=";
        };
        dontUnpack = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/fonts/truetype
          cp $src $out/share/fonts/truetype/lucon.ttf
          runHook postInstall
        '';
      })
    ];

    # Home Manager
    home-manager.users.${user} = _: {
      home = {
        stateVersion = defaults.system.nixosVersion;
        username = user;
        homeDirectory = "/home/${user}";
        sessionVariables.EDITOR = "nvim";

        packages = with pkgs; [
          # Games
          beammp-launcher
          lutris
          prismlauncher
          unrar # game archives

          # Music
          feishin
          tidal-hifi

          wl-clipboard
        ];
      };
      programs.home-manager.enable = true;
    };
  };
}
