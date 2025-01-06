# Lyra-specific applications
{pkgs, ...}: {
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

  # MacOS-specific packages
  environment.systemPackages = with pkgs; [
    # Development tools
    ollama
    dotnet-sdk

    # GUI Applications
    jetbrains.idea-ultimate
    jetbrains.clion
    jetbrains.pycharm-professional
    moonlight-qt

    # MacOS-specific apps
    raycast
    keka
    zoom-us
    yabai
    skhd
  ];

  # Homebrew configuration
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    masApps = {
      # Safari extensions
      "1Password for Safari" = 1569813296;
      "Kagi for Safari" = 1622835804;
      "AdGuard for Safari" = 1440147259;
      "SponsorBlock for Safari" = 1573461917;
      "Vimkey" = 1585682577;
      "Noir" = 1592917505;
      "Tailscale" = 1470499037;

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
      "indirect/homebrew-tap"
    ];
    brews = [
      "borders"
      "mas"
      "svim"
    ];
    casks = [
      "altserver"
      "mac-mouse-fix"
      "hex-fiend"
      "onyx"
      "1password"
      "orbstack"
      "proxyman"
      "vmware-fusion"
      "zen-browser"
      "ghostty"
      "mullvadvpn"
    ];
  };
}
