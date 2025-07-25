{
  pkgs,
  system,
  inputs,
  ...
}: {
  # Basic system packages
  environment.systemPackages = with pkgs; [
    # Development tools
    gnumake
    gcc
    entr # Run arbitrary commands when files change
    man-pages
    man-pages-posix
    uv
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
    gnupg
    gh
    gh-dash # gh cli extension
    gh-poi # gh cli extension
    hcloud
    just
    jq
    magic-wormhole-rs
    netcat
    sops
    ghq

    # Nix utils
    nix-tree
    nix-output-monitor
    nh
    nvd
    deadnix
    statix
    alejandra

    # GUI applications
    obsidian
    _1password-cli
    bvi

    inputs.determinate.packages.${system}.default
  ];

  # Base fonts
  fonts.packages = with pkgs; [
    open-sans
    inter
    # Maple Mono (Ligature TTF hinted)
    maple-mono.truetype-autohint
    # Maple Mono NF (Ligature hinted)
    maple-mono.NF
  ];
}
