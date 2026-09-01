_: {
  flake.nixOSModules.tiramisu = {
    pkgs,
    defaults,
    ...
  }: let
    inherit (defaults) user;
  in {
    system.stateVersion = defaults.system.nixosVersion;

    # Nix settings (read by Determinate Nixd from /etc/nix/nix.custom.conf)
    nix.settings = {
      experimental-features = "nix-command flakes parallel-eval impure-derivations";
      lazy-trees = true;
      warn-dirty = false;
      substituters = [
        "https://frostplexx.cachix.org"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        # CachyOS kernel binary cache
        "https://attic.xuyh0120.win/lantian"
      ];
      trusted-public-keys = [
        "frostplexx.cachix.org-1:kjkhnGNSkUvf5Mx8OEfhzaR830CUkDRglaKduAcr3UQ="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
      ];
      trusted-users = ["root" user];
      eval-cores = 0;
      auto-optimise-store = true;
      max-jobs = "auto";
    };

    # Networking
    networking = {
      hostName = "tiramisu";
      networkmanager.enable = true;
      interfaces.eth0.wakeOnLan.enable = true;
      firewall = {
        allowedUDPPorts = [9];
      };
    };

    time.timeZone = defaults.system.timeZone;
    i18n.defaultLocale = defaults.system.locale;

    boot = {
      initrd.systemd.enable = true;
      loader = {
        limine = {
          enable = true;
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
      xserver.videoDrivers = ["nvidia"];
      desktopManager.plasma6.enable = true;
      # The AeroThemePlasma shell requires SDDM for its login theme
      displayManager.sddm.enable = true;
      displayManager.defaultSession = "aerothemeplasma";
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
        ExecStart = "${pkgs.steam}/bin/steam -nochatui -nofriendsui -silent";
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

    # Steam
    programs = {
      fish.enable = true;
      steam = {
        enable = true;
        extest.enable = true;
      };
      _1password.enable = true;
      _1password-gui = {
        enable = true;
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = ["${user}"];
      };
    };

    users.users.${user} = {
      isNormalUser = true;
      description = user;
      initialPassword = "changeme";
      shell = pkgs.fish;
      extraGroups = ["wheel" "networkmanager" "video" "audio"];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIxoqb81bUGp//jr1iYhEMSq7XhzWLtGAJJTu81heOxQ"
      ];
    };

    services.openssh.enable = true;

    environment = {
      pathsToLink = ["/share/fish"];
      shells = [pkgs.fish];
      systemPackages = with pkgs; [
        wl-clipboard
        _1password-cli
        alejandra
        curl
        deadnix
        ffmpeg
        jq
        just
        nh
        nix-output-monitor
        nvd
        ripgrep
        sops
        statix
        uv
        wget
        vim
      ];

      plasma6.excludePackages = with pkgs.kdePackages; [
        plasma-browser-integration
        konsole
        elisa
        qrca
      ];
    };

    # Not needed for gaming config
    # documentation = {
    #   doc.enable = true;
    #   info.enable = true;
    # };

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
        sessionVariables = {
          NH_FLAKE = "$HOME/${defaults.paths.flake}";
          EDITOR = "vim";
        };
      };
      programs.home-manager.enable = true;
    };
  };
}
