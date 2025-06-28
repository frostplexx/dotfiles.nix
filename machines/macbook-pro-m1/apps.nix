# Lyra-specific applications
{
    pkgs,
    config,
    ...
}: {
    # MacOS-specific packages
    environment.systemPackages = with pkgs; [
        # GUI Applications
        jetbrains.idea-ultimate
        jetbrains.pycharm-professional
        # moonlight-qt
        ollama
        keka
        utm
        aerospace
        # mac app store cli
        mas
        switchaudio-osx
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
            # "1Password for Safari" = 1569813296;
            # "SponsorBlock for Safari" = 1573461917;
            # "Raycast Companion" = 6738274497;
            # "Noir" = 1592917505;
            # "Obsidian Web Clipper for Safari" = 6720708363;

            "Xcode" = 497799835;
            "Things" = 904280696;
            "eduVPN" = 1317704208;
            "Goodnotes" = 1444383602;
            "WhatsApp" = 310633997;
            # "Windows App" = 1295203466;
            "Testflight" = 899247664;
            "Tailscale" = 1475387142;
        };
        # This doesn't work, taps are defined in flake.nix and then mksystem.nix
        # taps = [];
        # https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-1878798641
        taps = builtins.attrNames config.nix-homebrew.taps;
        brews = [
            "wtfis"
            "displayplacer"
        ];
        casks = [
            "altserver"
            "chromium"
            "firefox"
            "cleanshot"
            "mac-mouse-fix"
            "orbstack"
            "1password@beta"
            "whisky"
            "raycast"
            "mullvadvpn"
            "zoom"
            "hex-fiend"
            "zen"
        ];
    };
}
