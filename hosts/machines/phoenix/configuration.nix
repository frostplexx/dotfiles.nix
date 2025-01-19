# Configuration for Phoenix gaming PC;
{
  config,
  pkgs,
  inputs,
  mkHomeManagerConfiguration,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Hardware-specific settings
    ../../base # Base configuration
    ./apps.nix # Phoenix-specific apps
    ./stylix.nix
    ./sunshine.nix
    ./vfio
  ];

  networking = {
    hostName = "pc-dev-phoenix";
    networkmanager.enable = true;
    interfaces.enp4s0.wakeOnLan.enable = true;

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [22];
    };
  };

  # System configuration
  time.timeZone = "Europe/Berlin";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  # Boot configuration
  # TODO: move this to hardware-configuration.nix
  boot = {
    kernelModules = ["i2c-dev"];
    kernelPackages = pkgs.linuxPackages_6_11;
    kernelParams = [
      # Hardware optimizations
      "acpi_enforce_resources=lax"
      "amd_iommu=on"
      "iommu=pt"
      "zswap.enabled=1"
      # Memory management
      "default_hugepagesz=2M"
      "hugepagesz=2M"
      "hugepages=1024"
      "transparent_hugepage=always"
    ];

    initrd = {
      systemd.enable = true;
      verbose = false;
    };

    consoleLogLevel = 0;
    loader = {
      timeout = 3;
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # Desktop environment
  services = {
    blueman = {
      enable = true;
    };
    gnome.gnome-keyring.enable = true;

    xserver = {
      enable = true;
      xkb.layout = "us";
      videoDrivers = ["nvidia"];
      # desktopManager.gnome.enable = true;
      displayManager = {
        # gdm.enable = true;
        # autoLogin = {
        #   enable = true;
        #   user = "daniel";
        # };
      };
    };

    udev = {
      # packages = with pkgs; [
      #   gnome-settings-daemon
      # ];
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = config.user.name;
      };
      defaultSession = "hyprland";
    };

    # desktopManager.plasma6.enable = true;

    # Hardware services
    hardware = {
      openrgb = {
        enable = true;
        motherboard = "amd";
        server.port = 6742;
      };
    };

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
    openssh.enable = true;
  };

  environment.sessionVariables = {
    # WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
  };

  # Exclude some packages from gnome
  # environment.gnome.excludePackages = with pkgs; [
  #   atomix
  #   cheese
  #   epiphany
  #   evince
  #   geary
  #   gedit
  #   gnome-characters
  #   gnome-music
  #   gnome-photos
  #   gnome-terminal
  #   gnome-tour
  #   hitori
  #   iagno
  #   tali
  #   totem
  #   yelp
  # ];

  # Hardware configuration
  hardware = {
    pulseaudio.enable = false;
    graphics.enable = true;
    i2c.enable = true;

    bluetooth = {
      enable = true; # enables support for Bluetooth
      powerOnBoot = true; # powers up the default Bluetooth controller on boot
    };

    opengl.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = false;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
  };

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  # Systemd user services
  systemd = {
    services = {
      "getty@tty1".enable = false;
      "autovt@tty1".enable = false;
    };
  };
  # System maintenance
  system = {
    autoUpgrade = {
      enable = true;
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "--print-build-logs"
      ];
      dates = "02:00";
      randomizedDelaySec = "45min";
    };
  };

  # Environment settings
  environment.variables = {
    FREETYPE_PROPERTIES = "cff:no-stem-darkening=0 autofitter:no-stem-darkening=0";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # User configuration
  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    users.${config.user.name}.extraGroups = ["wheel" "video" "audio" "docker"];
  };

  # File system configuration
  fileSystems."/mnt/share" = {
    device = "//u397529.your-storagebox.de/backup";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=1000,gid=100"];
  };

  fileSystems."/mnt/nas" = {
    device = "//192.168.1.122/data";
    fsType = "cifs";
    options = let
      # this line prevents hanging on network split
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in ["${automount_opts},credentials=/etc/nixos/nas-secrets"];
  };

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    systemService = true;
    user = "daniel";
    group = "wheel";
    dataDir = "/home/daniel/syncthing";
    settings = {
      devices = {
        "steamdeck" = {id = "H7CT2Y7-RNY2HRN-3N4U2BJ-TM5V3DE-URDDL6K-3X2USMG-DHHNHC7-TFPDXAI";};
      };
      folders = {
        "VintageStory" = {
          path = "/home/daniel/.config/VintagestoryData";
          devices = ["steamdeck"];
          ignorePerms = true;
        };
      };
    };
  };

  # Home Manager configuration
  home-manager.users.${config.user.name} = mkHomeManagerConfiguration.withModules [
    "editor"
    # "firefox"
    # "kitty"
    "wezterm"
    "ghostty"
    "git"
    "shell"
    # "plasma"
    # "gnome"
    "hyprland"
    "nixcord"
    "spicetify"
  ];
}
