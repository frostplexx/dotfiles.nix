# Base applications that should be available on all systems
{ pkgs, ... }: {
  # Basic system packages
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    neovim
    lazygit
    nodePackages.nodejs
    llvm
    gnumake
    gcc
    vscode

    # CLI utilities
    ffmpeg
    imagemagick
    nmap
    btop
    pandoc
    fastfetch
    ripgrep
    sshpass
    wget
    curl

    # GUI applications
    obsidian
    _1password-cli
    transmission_4
  ];

  # Base fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = ["JetBrainsMono"]; })
  ];
}