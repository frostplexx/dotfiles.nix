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
    yabai
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
      "Kagi for Safari" = 1622835804;
      "AdGuard for Safari" = 1440147259;
      "SponsorBlock for Safari" = 1573461917;
      "Noir" = 1592917505;
      "Tailscale" = 1475387142;

      "Xcode" = 497799835;
      "Things" = 904280696;
      "eduVPN" = 1317704208;
      "Goodnotes" = 1444383602;
      "WhatsApp" = 310633997;
      "Window App" = 1295203466;
      "Enchanted" = 6474268307;
    };
    taps = [
      "FelixKratz/formulae"
      "homebrew/services"
      "indirect/homebrew-tap"
    ];
    brews = [
      "borders"
      "mas"
    ];
    casks = [
      "altserver"
      "ollama"
      "mac-mouse-fix"
      "hex-fiend"
      "onyx"
      "1password"
      "orbstack"
      "proxyman"
      "vmware-fusion"
      "cursor"
      "zen-browser"
      "ghostty"
      "mullvadvpn"
      "raycast"
    ];
  };
}
