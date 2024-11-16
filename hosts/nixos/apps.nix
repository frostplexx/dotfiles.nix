{ pkgs, inputs, vars, ... }:

{

  # Set start up applications
  # shitty version of this https://github.com/nix-community/home-manager/issues/3447#issuecomment-1328294558
  environment.etc = {
    "xdg/autostart/steam.desktop".source = pkgs.steam + "/share/applications/steam.desktop";
    # "xdg/autostart/solaar.desktop".source = pkgs.solaar + "/share/applications/solaar.desktop";
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

  # install steam
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    # Set up some settings for 1password
    _1password-gui = {
        enable = true;
        # Certain features, including CLI integration and system authentication support,
        # require enabling PolKit integration on some desktop environments (e.g. Plasma).
        polkitPolicyOwners = [ vars.user ];
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
    pkg-config
    xclip # for copying to clipboard


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
    _1password-cli
    _1password-gui
    papirus-icon-theme
    simplescreenrecorder
    haruna

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
