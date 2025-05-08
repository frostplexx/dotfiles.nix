# This function creates a NixOS system based on our VM setup for a
# particular architecture.
{
    inputs,
    nixpkgs,
    overlays,
    ...
} @ args: name: {
    system,
    user,
    hm-modules ? [],
}: let
    inherit (pkgs.stdenv) isDarwin;
    # The config files for this system.
    machineConfig = ../machines/${name};

    # Settings for Package management
    nixpkgsConfig = {
        allowUnfree = true;
        allowUnsupportedSystem = false;
        allowBroken = true;
        allowInsecure = true; # Fixed typo here
    };

    # NixOS vs nix-darwin functions
    systemFunc =
        if isDarwin
        then inputs.darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;
    home-manager =
        if isDarwin
        then inputs.home-manager.darwinModules
        else inputs.home-manager.nixosModules;

    # Nixpkgs alias with settings applied that we can pass through to our machines
    pkgs = import inputs.nixpkgs {
        inherit system;
        inherit overlays;
        config = nixpkgsConfig;
    };

    # Remote git lfs storage of assets
    assets = pkgs.fetchFromGitHub {
        owner = "frostplexx";
        repo = "dotfiles-assets.nix";
        rev = "982795ccc1e09b48129257224101136e1adacbf6";
        hash = "sha256-Oz3VYS1Q4KB6CMQJnFlif4Aob6kZxEixHyFqeTR1ZGk=";
    };

    # Merge the explicitly needed attributes with all the extra ones captured in args.
    machineConfigArgs = {inherit system user pkgs inputs assets;} // args;

    # Build the home configuration from the modules
    mkHomeConfig = {
        modules ? [],
        user,
    }: {
        # Import the fixed global config and each applied package
        imports =
            [
                ../home
            ]
            ++ builtins.map (name: ../home/${name}) modules;
        _module.args = {inherit user;};
    };
in
    systemFunc rec {
        inherit system;
        inherit (inputs.nixpkgs) lib;

        modules = [
            # Apply our overlays. Overlays are keyed by system type so we have
            # to go through and apply our system type. We do this first so
            # the overlays are available globally.
            {nixpkgs.overlays = overlays;}
            # Apply the config we defined above
            {nixpkgs.config = nixpkgsConfig;}
            # New and faster replacement for cppNix (the default nix interpreter)
            inputs.lix-module.nixosModules.default
            # Import our machine config with all available arguments
            #TODO: this is weird and should get changed
            ({modulesPath, ...}: import machineConfig (machineConfigArgs // {inherit modulesPath;}))
            # Trust myself
            {nix.settings.trusted-users = ["root" user];}

            # Home manager configuration
            home-manager.home-manager
            {
                nixpkgs.config = nixpkgsConfig;
                # nixpkgs.overlays = overlays;
                # Why do darwin and linux use different stateVerions???
                system.stateVersion =
                    if isDarwin
                    then 6
                    else "24.05";
                home-manager = {
                    useGlobalPkgs = true;
                    useUserPackages = true;
                    # On activation move existing files by appending the given file extension rather than exiting with an error.
                    # https://nix-community.github.io/home-manager/nixos-options.xhtml#nixos-opt-home-manager.backupFileExtension
                    backupFileExtension = "backup";
                    # Extra specialArgs passed to Home Manager. This option can be used to pass additional arguments to all modules.
                    extraSpecialArgs = {inherit inputs system assets;};
                    # Home Manager Modules
                    sharedModules = [
                        # Use Nixcord for declaratively managing discord
                        inputs.nixcord.homeModules.nixcord
                        # 1Password shell integration
                        inputs._1password-shell-plugins.hmModules.default
                        inputs.nixkit.homeModules.default
                        inputs.spicetify-nix.homeManagerModules.spicetify
                    ];
                    # Apply only the specific modules from hm-modules
                    users.${user} = mkHomeConfig {
                        inherit user;
                        modules = hm-modules;
                    };
                };
            }
            {
                # We expose some extra arguments so that our modules can parameterize
                # better based on these values.
                config._module.args = {
                    currentSystem = system;
                    currentSystemName = name;
                    currentSystemUser = user;
                    inherit user system inputs assets;
                };
            }

            (
                # Darwin specific stuff
                if isDarwin
                then {
                    imports = [
                        inputs.nix-homebrew.darwinModules.nix-homebrew
                        inputs.lazykeys.darwinModules.default
                        inputs.nixkit.darwinModules.default
                    ];
                    nix-homebrew = {
                        # Install Homebrew under the default prefix
                        enable = true;
                        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                        enableRosetta = false;
                        # User owning the Homebrew prefix
                        inherit user;
                        # Optional: Enable fully-declarative tap management
                        # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
                        mutableTaps = false;
                        taps = with inputs; {
                            "homebrew/homebrew-core" = homebrew-core;
                            "homebrew/homebrew-cask" = homebrew-cask;
                            "nikitabobko/homebrew-tap" = homebrew-nikitabobko;
                        };
                    };
                }
                # NixOS specific stuff
                else {
                    imports = [
                        inputs.nixkit.darwinModules.default
                    ];
                }
            )
        ];
    }
