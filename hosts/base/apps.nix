# Base applications that should be available on all systems
{pkgs, ...}: {
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
    vscode
    man-pages
    man-pages-posix
    jq

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
  # ++ [
  #   inputs.zen-browser.packages."${system}".specific
  # ];

  # Base fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    jetbrains-mono
  ];
}
