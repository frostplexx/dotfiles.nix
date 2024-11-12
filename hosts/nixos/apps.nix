{ pkgs, inputs, ... }:

{

  # Set start up applications
  # shitty version of this https://github.com/nix-community/home-manager/issues/3447#issuecomment-1328294558
  environment.etc = {
    "xdg/autostart/solaar.desktop".source = pkgs.solaar + "/share/applications/solaar.desktop";
    "xdg/autostart/steam.desktop".source = pkgs.steam + "/share/applications/steam.desktop";
  };


  # install steam
  programs = {
    gamescope = {
      enable = true;
      capSysNice = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
      # gamescopeSession.enable = true;
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Development tools
    lazygit
    nodePackages.nodejs
    gcc
    libgcc
    cargo
    llvm
    gnumake
    inputs.yuki.packages.${pkgs.system}.default

    # CLI utilities
    ffmpeg
    imagemagick
    nmap
    btop
    pandoc
    fastfetch
    ripgrep
    sshpass

    # GUI Applications
    obsidian
    spotify
    transmission_4
    vesktop
    _1password-cli
    _1password-gui
    papirus-icon-theme

    # Gaming related
    vintagestory
    linuxKernel.packages.linux_6_6.xone
    gamemode
    solaar
    lutris
    cowsay
    filelight
  ];

  # Fonts
  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
}
