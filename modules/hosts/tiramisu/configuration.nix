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
      eth0.wakeOnLan.enable = true;
      firewall = {
        allowedUDPPorts = [ 9 ];
      };
    };

    time.timeZone = defaults.system.timeZone;
    i18n.defaultLocale = defaults.system.locale;

    boot = {
      initrd.systemd.enable = true;
      loader = {
        limine.enable = true;
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
      displayManager.plasma-login-manager.enable = true;
    };

    hardware = {
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

    # User configuration
    # Sops decryption for system-level secrets
    sops = {
      age = {
        keyFile = "/home/${user}/.config/sops/age/keys.txt";
        sshKeyPaths = [];
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
        _1password-cli
        alejandra
        curl
        deadnix
        ffmpeg
        gcc
        gh
        gnumake
        gnupg
        jq
        just
        netcat
        nh
        nix-output-monitor
        nix-tree
        nmap
        nvd
        ripgrep
        sops
        sshpass
        statix
        uv
        wget
        secretspec
        poppler-utils
      ];

      plasma6.excludePackages = with pkgs.kdePackages; [
        plasma-browser-integration
        konsole
        elisa
        qrca
      ];
    };

    documentation = {
      doc.enable = true;
      info.enable = true;
    };

    fonts.packages = with pkgs; [
      monocraft
      maple-mono.NF
    ];

    # Home Manager
    home-manager.users.${user} = _: {
      home = {
        stateVersion = defaults.system.nixosVersion;
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
