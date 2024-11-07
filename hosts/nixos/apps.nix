{ pkgs, inputs, ... }:

{

  # install steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Development tools
    lazygit
    nodePackages.nodejs
    rustc
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
