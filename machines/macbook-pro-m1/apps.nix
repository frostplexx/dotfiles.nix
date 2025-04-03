# Lyra-specific applications
{pkgs, ...}: {
  # MacOS-specific packages
  environment.systemPackages = with pkgs; [
    # GUI Applications
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.pycharm-professional
    jetbrains.datagrip
    moonlight-qt

    # MacOS-specific apps
    # raycast
    keka
    zoom-us
    utm
    aerospace
    # mac app store cli
    mas
  ];

  services.jankyborders = {
    enable = true;
    package = pkgs.jankyborders;

    style = "round";
    width = 3.0;
    hidpi = true;
    active_color = "0xffac8fd4";
    inactive_color = "0xffac8fd4";
    whitelist = [
      "ghostty"
      "kitty"
    ];
  };

  # Homebrew configuration
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    masApps = {
      # Safari extensions
      # "1Password for Safari" = 1569813296;
      # "AdGuard for Safari" = 1440147259;
      # "SponsorBlock for Safari" = 1573461917;
      # "Raycast Companion" = 6738274497;
      # "Super Agent for Safari" = 1568262835;
      # "Noir" = 1592917505;
      # "Tailscale" = 1475387142;
      # "Obsidian Web Clipper" = 6720708363;
      #
      # "Xcode" = 497799835;
      # "Things" = 904280696;
      # "eduVPN" = 1317704208;
      # "Goodnotes" = 1444383602;
      # "WhatsApp" = 310633997;
      # "Windows App" = 1295203466;
      # "Parcel" = 639968404;
    };
    # This doesn't work, taps are defined in flake.nix and then mksystem.nix
    # taps = [];
    brews = [
    ];
    casks = [
      "altserver"
      "ollama"
      "cleanshot"
      "mac-mouse-fix"
      "onyx"
      "orbstack"
      "1password@beta"
      "proxyman"
      "zen-browser"
      "raycast"
      "mullvadvpn"
      "aerospace"
      "whisky"
      "betterdisplay"
    ];
  };
}
