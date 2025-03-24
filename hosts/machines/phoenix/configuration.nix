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
    ./sunshine.nix
  ];

  networking = {
    hostName = "pc-dev-phoenix";
    networkmanager.enable = true;
    interfaces.enp4s0.wakeOnLan.enable = true;
    nameservers = [
      194.242
      .2
      .4
      9.9
      .9
      .9
    ];

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

  # Desktop environment
  services = {
    tailscale.enable = true;

    xserver = {
      enable = true;
      xkb.layout = "us";
      videoDrivers = ["nvidia"];
    };

    displayManager = {
      sddm = {
        enable = true;
        # wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = config.user.name;
      };
      defaultSession = "plasmax11";
    };

    desktopManager.plasma6.enable = true;

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

  # Hardware configuration
  hardware = {
    pulseaudio.enable = false;
    graphics.enable = true;

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

  # User configuration
  programs.zsh.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    users.${config.user.name}.extraGroups = ["wheel" "video" "audio" "docker"];
  };

  # Home Manager configuration
  home-manager.users.${config.user.name} = mkHomeManagerConfiguration.withModules [
    "editor"
    "wezterm"
    "git"
    "shell"
    "plasma"
    "nixcord"
  ];
}
