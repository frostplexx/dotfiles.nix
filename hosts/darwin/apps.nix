{ pkgs, ... }:
{
  # Allow non-free apps
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Yuki configuration
  programs.yuki = {
    enable = true;
    settings = {
      system_packages_path = "~/dotfiles.nix/hosts/darwin/apps.nix";
      homebrew_packages_path = "~/dotfiles.nix/hosts/darwin/apps.nix";
      auto_commit = true;
      auto_push = false;
      install_message = "installed <package>";
      uninstall_message = "removed <package>";
      install_command = "cd ~/dotfiles.nix ; make";
      uninstall_command = "cd ~/dotfiles.nix; make";
      update_command = "cd ~/dotfiles.nix; make update";
    };
  };

  # Packages managed by Nix
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    neovim
    lazygit
    nodePackages.nodejs
    llvm
    gnumake
    vscode

    # CLI utilities
    ffmpeg
    imagemagick
    nmap
    btop
    pandoc
    fastfetch
    nixfmt-rfc-style
    ripgrep
    sshpass
    skhd

    # GUI Applications
    obsidian
    spotify
    transmission_4
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    _1password-cli
    raycast # Spotlight replacement
    aerospace # macOS window manager
    keka # Archive utility
    zoom-us # Video conferencing
    tailscale
  ];

  fonts.packages = [
    (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    masApps = {
      "1Password for Safari" = 1569813296;
      "Xcode" = 497799835;
      "Things" = 904280696;
      "eduVPN" = 1317704208;
      "Goodnotes" = 1444383602;
      "WhatsApp" = 310633997;
      "Window App" = 1295203466;
    };
    taps = [
      "FelixKratz/formulae"
      "homebrew/services"
      "nikitabobko/tap"
    ];
    brews = [
      "mas"
    ];
    casks = [
      "altserver"
      "mac-mouse-fix"
      "shottr"
      "hex-fiend"
      "onyx"
      "kitty"
      "1password"
      "orbstack"
      "tower"
      "proxyman"
      "chromium"
      "vmware-fusion"
    "ollama"
    ];
  };
}
