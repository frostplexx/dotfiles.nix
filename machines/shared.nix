{pkgs, ...}: {
  # Nix settings import
  imports = [
    ./nix.nix
  ];

  # Basic system packages
  environment.systemPackages = with pkgs; [
    # Development tools
    lazygit
    gnumake
    gcc
    entr # Run arbitrary commands when files change
    man-pages
    man-pages-posix
    #TODO: move to home manager: jq

    # CLI utilities
    ffmpeg
    imagemagick
    nmap
    pandoc
    ripgrep
    sshpass
    wget
    curl
    gnupg

    nix-tree
    nix-output-monitor
    nh
    nvd

    # GUI applications
    obsidian
    _1password-cli
    transmission_4
    spotify
    imhex
    sublime4
  ];

  # Base fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];
}
