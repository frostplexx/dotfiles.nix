# Configuration for Lyra MacBook
_: {
  imports = [
    ../shared.nix # Base configuration
    ./apps.nix # Lyra-specific apps
    ./custom_icons/custom_icons.nix # Custom application icons
    ../../lib/custom-icons.nix
  ];
}
