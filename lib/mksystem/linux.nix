# Linux (NixOS) specific system modules and options.
# This is imported only when building for Linux systems.
{inputs}: {
    imports = [
        # NixKit NixOS modules
        inputs.nixkit.nixosModules.default
        inputs.stylix.nixosModules.stylix
    ];
}
