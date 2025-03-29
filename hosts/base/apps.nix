# Base applications that should be available on all systems
{
  pkgs,
  # vars,
  ...
}: {
  # Basic system packages
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    neovim
    zellij
    lazygit
    nodePackages.nodejs
    llvm
    lldb
    gnumake
    gcc
    entr # Run arbitrary commands when files change
    man-pages
    man-pages-posix
    jq
    unzip
    python3

    # CLI utilities
    ffmpeg
    imagemagick
    nmap
    pandoc
    ripgrep
    sshpass
    wget
    curl
    git-secret

    nixpkgs-review
    nix-update
    nix-tree
    nix-output-monitor

    # GUI applications
    obsidian
    _1password-cli
    transmission_4
    spotify
    imhex
  ];

  # Base fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];
}
