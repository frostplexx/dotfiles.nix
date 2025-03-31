# Configuration for Phoenix gaming PC;
{
  user,
  pkgs,
  inputs,
  modulesPath,
  ...
}: {
  imports = [
    ./hardware-configuration.nix # Hardware-specific settings
    ./apps.nix # Phoenix-specific apps
    ../shared.nix
    ./sunshine.nix
    (import ./services.nix)
    {inherit user;}
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  networking = {
    hostName = "pc-dev-phoenix";
    networkmanager.enable = true;
    interfaces.enp4s0.wakeOnLan.enable = true;
    nameservers = [
      "194.242.2.4"
      "9.9.9.10"
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
    users.${user}.extraGroups = ["wheel" "video" "audio" "docker"];
  };
  # nixpkgs.overlays = import ../../lib/overlays.nix;
}
