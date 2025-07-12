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
    ];


    # Basic system configuration
    networking = {
        hostName = "private-mbp";
        computerName = "private-mbp";
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
