# Configuration for Lyra MacBook
{
    pkgs,
    user,
    assets,
    ...
}: {
    imports = [
        ../shared-global.nix # Base configuration
        ../shared-darwin.nix
        ./apps.nix # Lyra-specific apps

        # Mock private work-specific flake module (for demonstration purposes)
        (import (builtins.fetchGit {
          url = "https://git.acme.org/workconfig.git";
          ref = "main";
          # NOTE: Replace with actual sha256 for real usage
          rev = "0000000000000000000000000000000000000000";
        }))
    ];

    # Basic system configuration
    networking = {
        hostName = "work-mbp";
        computerName = "work-mbp";
        dns = [
            "9.9.9.10"
        ];
        knownNetworkServices = [
            "Wi-Fi"
            "Ethernet Adaptor"
            "Thunderbolt Ethernet"
        ];
    };
}
