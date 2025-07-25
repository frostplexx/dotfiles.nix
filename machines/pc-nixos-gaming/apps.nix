{pkgs, ...}: {
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
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
    openrgb-with-all-plugins

    xorg.xrandr
    xorg.xinput
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
