# Lyra-specific applications
{
  pkgs,
  config,
  ...
}: {
  # MacOS-specific packages
  environment.systemPackages = with pkgs; [
    # GUI Applications
    # jetbrains.idea-ultimate
    # jetbrains.pycharm-professional
    # ollama
    keka
    utm
    mas
    switchaudio-osx
    whisky
    wtfis
    hexfiend
    claude-code
    skimpdf
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
      "SponsorBlock for Safari" = 1573461917;
      # "Raycast Companion" = 6738274497;
      "Noir" = 1592917505;
      "uBlock Origin Lite" = 6745342698;
      "Obsidian Web Clipper for Safari" = 6720708363;

      # "Xcode" = 497799835;
      "Things" = 904280696;
      "eduVPN" = 1317704208;
      "Goodnotes" = 1444383602;
      "WhatsApp" = 310633997;
      "Windows App" = 1295203466;
      "Testflight" = 899247664;
      "Tailscale" = 1475387142;
      "System Color Picker" = 1545870783;
      "Numbers" = 409203825;
      "Keynote" = 409183694;
    };
    # This doesn't work, taps are defined in flake.nix and then mksystem.nix
    # taps = [];
    # https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-1878798641
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "displayplacer"
    ];
    casks = [
      "altserver"
      "chromium"
      "ghostty@tip"
      "firefox"
      "cleanshot"
      "mac-mouse-fix"
      "orbstack"
      "zoom"
      "zen"
      "1password"
      # TODO: Move to nix once available
      "font-sf-pro"
      "font-sf-mono"
      "sf-symbols"
    ];
  };
}
