# Lyra-specific applications
{
  pkgs,
  config,
  ...
}: {
  # MacOS-specific packages
  environment.systemPackages = with pkgs; [
    # Your apps here
    mas
    switchaudio-osx
    wtfis
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
    # Appstore apps here
    masApps = {
      "Testflight" = 899247664;
      "Tailscale" = 1475387142;
      "System Color Picker" = 1545870783;
    };
    # This doesn't work, taps are defined in flake.nix and then mksystem.nix
    # taps = [];
    # https://github.com/zhaofengli/nix-homebrew/issues/5#issuecomment-1878798641
    taps = builtins.attrNames config.nix-homebrew.taps;
    brews = [
      "displayplacer"
    ];
    # apps through homebrew that arent available on nixpkgs
    casks = [
      "orbstack"
      "ghostty@tip"
    ];
  };
}
