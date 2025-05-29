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
            # "AdGuard for Safari" = 1440147259;
            # "SponsorBlock for Safari" = 1573461917;
            # "Raycast Companion" = 6738274497;
            # "Super Agent for Safari" = 1568262835;
            # "Noir" = 1592917505;
            # "Tailscale" = 1475387142;
            # "Obsidian Web Clipper" = 6720708363;

            "Xcode" = 497799835;
            "Things" = 904280696;
            "eduVPN" = 1317704208;
            "Goodnotes" = 1444383602;
            "WhatsApp" = 310633997;
            "Windows App" = 1295203466;
            "Parcel" = 639968404;
        };
        # This doesn't work, taps are defined in flake.nix and then mksystem.nix
        # taps = [];
        # https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-1878798641
        taps = builtins.attrNames config.nix-homebrew.taps;
        brews = [
            # "coreutils"
            "wtfis"
            "displayplacer"
        ];
        casks = [
            "altserver"
            "firefox"
            "cleanshot"
            "mac-mouse-fix"
            "raycast"
            "onyx"
            "orbstack"
            "1password@beta"
            "proxyman"
            "zen"
            "whisky"
            "mullvadvpn"
            "zoom"
            "spotify"
        ];
    };
}
