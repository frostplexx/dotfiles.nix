{
  pkgs,
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
    solaar
    linuxKernel.packages.linux_zen.xone
    ckan
    openrgb-with-all-plugins
    furmark

    # Desktop utilities
    _1password-gui
    papirus-icon-theme
    simplescreenrecorder
    kdePackages.filelight
    vlc
    xclip
    cifs-utils

    #Plasma specific
    kde-rounded-corners
    gnome-themes-extra # Breeze themes are included here
  ];
}
