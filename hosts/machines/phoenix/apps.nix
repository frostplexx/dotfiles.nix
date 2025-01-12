{
  pkgs,
  inputs,
  vars,
  ...
}: {
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
    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "-w 1720"
        "-h 1080"
        "-S stretch"
        "-f"
        "-e"
      ];
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };

    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [vars.user];
    };
  };

  # Additional packages specific to Phoenix
  environment.systemPackages = with pkgs; [
    # Gaming
    steam
    lutris
    gamemode
    # vintagestory
    solaar
    linuxKernel.packages.linux_6_11.xone
    ckan
    openrgb-with-all-plugins
    furmark

    # Desktop utilities
    _1password-gui
    papirus-icon-theme
    simplescreenrecorder
    filelight
    vlc
    xclip
    inputs.zen-browser.packages."${system}".default
    # inputs.ghostty.packages.x86_64-linux.default

    cifs-utils

    #Plasma specific
    # kde-rounded-corners
    # gnome-themes-extra # Breeze themes are included here

    # Gnome specific
    gtk3
    dconf
    adwaita-icon-theme
    gsettings-desktop-schemas
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    gnomeExtensions.space-bar
    gnomeExtensions.tactile
    gnomeExtensions.undecorate
    gnomeExtensions.appindicator
    gnomeExtensions.user-themes
    gnome-keyring
    libgnome-keyring
    libsecret
    gnome-tweaks

    # Development
    inputs.yuki.packages.${system}.default
  ];
}
