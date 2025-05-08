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

    # Gaming-specific programs
    programs = {
        _1password-gui = {
            enable = true;
            polkitPolicyOwners = ["daniel"];
        };

        steam = {
            enable = true;
            remotePlay.openFirewall = true;
            dedicatedServer.openFirewall = true;
            localNetworkGameTransfers.openFirewall = true;
        };
    };

    # Additional packages specific to Phoenix
    environment.systemPackages = with pkgs; [
        # Gaming
        steam
        lutris
        gamemode
        # vintagestory
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
        flameshot
        polkit

        #Gnome specific
        # adwaita-icon-theme
        # gnome-themes-extra
        # gnomeExtensions.blur-my-shell
        # gnomeExtensions.gsconnect
        # gnomeExtensions.just-perfection
        # gnomeExtensions.dash-to-dock
        # gnomeExtensions.space-bar
    ];
}
