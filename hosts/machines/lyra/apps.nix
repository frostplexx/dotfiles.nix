# Lyra-specific applications
{pkgs, ...}: {
  # MacOS-specific packages
  environment.systemPackages = with pkgs; [
    # Development tools
    dotnet-sdk

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
    # talosctl
    # kubectl
  ];

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
      "1Password for Safari" = 1569813296;
      "AdGuard for Safari" = 1440147259;
      "SponsorBlock for Safari" = 1573461917;
      "Raycast Companion" =  6738274497;
      "Super Agent for Safari" = 1568262835;
      "Noir" = 1592917505;
      "Tailscale" = 1475387142;

      "Xcode" = 497799835;
      "Things" = 904280696;
      "eduVPN" = 1317704208;
      "Goodnotes" = 1444383602;
      "WhatsApp" = 310633997;
      "Windows App" = 1295203466;
    };
    taps = [
      "FelixKratz/formulae"
      "homebrew/services"
      "nikitabobko/tap"
    ];
    brews = [
      "borders"
      "mas"
      "fluxcd/tap/flux"
    ];
    casks = [
      "altserver"
      "ollama"
      "mac-mouse-fix"
      "onyx"
      "orbstack"
      "1password@beta"
      "proxyman"
      "zen-browser"
      "raycast"
      "mullvadvpn"
      "aerospace"
      "betterdisplay"
    ];
  };
}
