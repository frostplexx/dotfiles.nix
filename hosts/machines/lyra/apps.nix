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
    # yabai
    # skhd
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
      "indirect/homebrew-tap"
      "nikitabobko/tap/aerospace"
    ];
    brews = [
      "borders"
      "mas"
    ];
    casks = [
      "altserver"
      "ollama"
      "mac-mouse-fix"
      "onyx"
      "orbstack"
      "1password@beta"
      "proxyman"
      "zen-browser@twilight"
      "raycast"
      "mullvadvpn"
      "aerospace"
    ];
  };
}
