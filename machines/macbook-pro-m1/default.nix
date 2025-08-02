# Configuration for Lyra MacBook
{
  pkgs,
  user,
  assets,
  ...
}: {
  imports = [
    ../shared.nix # Base configuration
    ./apps.nix # Lyra-specific apps
  ];

  programs.opsops.enable = true;

  # Basic system configuration
  networking = {
    # use whatever name you want
    hostName = "macbook-pro-m1";
    computerName = "macbook-pro-m1";
    dns = [
      "9.9.9.10"
    ];
    knownNetworkServices = [
      "Wi-Fi"
      "Ethernet Adaptor"
      "Thunderbolt Ethernet"
    ];
  };
  time.timeZone = "Europe/Berlin";

  # Security settings
  security.pam.services.sudo_local.touchIdAuth = true;

  # You can enable the fish shell and manage fish configuration and plugins with Home Manager, but to enable vendor fish completions provided by Nixpkgs you
  # will also want to enable the fish shell in /etc/nixos/configuration.nix:
  programs.fish.enable = true;

  # Add ~/.local/bin to PATH
  environment = {
    # https://github.com/nix-community/home-manager/pull/2408
    pathsToLink = ["/share/fish"];
    shells = [pkgs.fish];
  };
  # User configuration
  users = {
    users.${user} = {
      home = "/Users/${user}";
      description = user;
      shell = pkgs.fish;
      uid = 501;
    };
    # https://github.com/nix-darwin/nix-darwin/issues/1237#issuecomment-2562230471
    knownUsers = [user];
  };

  # System defaults and preferences
  system = {
    primaryUser = user;
    startup.chime = false;

    # Post-activation scripts
    activationScripts = {
      postActivation = {
        text = ''
        '';
      };
    };

    defaults = {
    # use whatever name you want
      smb.NetBIOSName = "macbook-pro-m1";
    };
  };
}
