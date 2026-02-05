{inputs, ...}: {
    # Define the systems for per-system outputs
    systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
    ];

    # Make nixpkgs available per-system
    perSystem = {
        pkgs,
        system,
        ...
    }: {
        # Default formatter
        formatter = pkgs.alejandra;
    };
}
