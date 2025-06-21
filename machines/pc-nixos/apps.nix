{pkgs, ...}: {
    # Autostart applications
    environment.etc = {
        "xdg/autostart/steam.desktop".source = pkgs.steam + "/share/applications/steam.desktop";
        "xdg/autostart/1password.desktop".source = pkgs._1password-gui + "/share/applications/1password.desktop";
        "xdg/autostart/solaar.desktop".text = ''
            [Desktop Entry]
            Type=Application
            Name=Solaar
            Exec=solaar --window=hide
            Icon=solaar
            Terminal=false
            Categories=Utility;
        '';
    };

    services.gvfs.enable = true;
    programs = {
        _1password-gui = {
            enable = true;
            polkitPolicyOwners = ["daniel"];
        };
        gamescope = {
            enable = true;
            capSysNice = true;
        };
        steam = {
            enable = true;
            remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
            dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
            localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
        };

        thunar = {
            enable = true;
            plugins = with pkgs.xfce; [
                thunar-archive-plugin
                thunar-volman
            ];
        };
    };

    # Additional packages specific to Phoenix
    environment.systemPackages = with pkgs; [
        # Gaming
        steam
        steam-run
        lutris
        gamemode
        gamescope
        kbd # for chvt command
        mangohud
        prismlauncher
        solaar
        linuxKernel.packages.linux_zen.xone
        ckan
        openrgb-with-all-plugins

        # Desktop utilities
        _1password-gui
        papirus-icon-theme
        simplescreenrecorder
        kdePackages.filelight
        vlc
        xclip
        cifs-utils

        xorg.xrandr
        xorg.xinput
        picom # Compositor for transparency/animations
        xfce.thunar
        xfce.tumbler # thunar thumbnails
        xfce.thunar-archive-plugin
        xfce.thunar-volman
        ffmpegthumbnailer # Video thumbnails
        gvfs # For trash support
        flameshot
        polkit
        catppuccin-gtk
        papirus-icon-theme
        catppuccin-cursors
        feh
        networkmanager
        imlib2
        libsecret
    ];
}
