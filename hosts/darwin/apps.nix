{ pkgs, inputs, ... }:
{
  # Allow non-free apps
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;

  # Yuki configuration
  programs.yuki = {
    enable = true;
    settings = {
      system_packages_path =
        if pkgs.stdenv.isDarwin then
          "~/dotfiles/hosts/darwin/apps.nix"
        else
          "~/dotfiles/hosts/nixos/apps.nix";
      homebrew_packages_path = "~/dotfiles/hosts/darwin/apps.nix";
      auto_commit = true;
      auto_push = false;
      install_message = "installed <package>";
      uninstall_message = "removed <package>";
      install_command = "make";
      uninstall_command = "make";
      update_command = "make update";
    };
  };

  # Packages managed by Nix
  environment.systemPackages = with pkgs; [
    # Development tools
    git
    neovim
    lazygit
    nodePackages.nodejs
    rustc
    cargo
    llvm
    gnumake
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

    # GUI Applications
    obsidian
    spotify
    transmission_4
    jetbrains.idea-ultimate
    jetbrains.pycharm-professional
    vesktop
    _1password-cli
    raycast # Spotlight replacement
    aerospace # macOS window manager
    keka # Archive utility
    utm # Virtualization
    zoom-us # Video conferencing
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
      "jupyterlab"
    ];
    casks = [
      "altserver"
      "mac-mouse-fix"
      "shottr"
      "hex-fiend"
      "deskpad"
      "onyx"
      "tailscale"
      "basictex"
      "visual-studio-code"
      "kitty"
      "insomnia"
      "1password"
      "orbstack"
      "tower"
      "termius"
      "proxyman"
    ];
  };
}
