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
    assets = pkgs.fetchgit {
        url = "https://github.com/frostplexx/dotfiles-assets.nix";
        branchName = "main";
        hash = "sha256-pnHMrmAW9cSa/KzTKcHAR63H7LotU2U0M93YwUuhoi8=";
        fetchLFS = true;
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

        modules =
            [
                # Apply our overlays. Overlays are keyed by system type so we have
                # to go through and apply our system type. We do this first so
                # the overlays are available globally.
                {nixpkgs.overlays = overlays;}
                # Apply the config we defined above
                {nixpkgs.config = nixpkgsConfig;}
                # Import our machine config with all available arguments
                #TODO: this is weird and should get changed
                ({modulesPath, ...}: import machineConfig (machineConfigArgs // {inherit modulesPath;}))
                # Trust myself
                {nix.settings.trusted-users = ["root" user];}

                # {
                #     home-manager.sharedModules = [
                #         ({
                #             lib,
                #             config,
                #             ...
                #         }: {
                #             # Disable old style linking of applications in home-manager
                #             targets.darwin.linkApps.enable = lib.mkForce false;
                #             home.activation.copyApplications = let
                #                 targetDir = "${config.home.homeDirectory}/Applications/Home Manager Apps";
                #                 homeApps = pkgs.buildEnv {
                #                     name = "home-applications";
                #                     paths = config.home.packages;
                #                     pathsToLink = "/Applications";
                #                 };
                #             in
                #                 lib.hm.dag.entryAfter ["writeBoundary"] ''
                #                     # Set up home applications.
                #                     echo "setting up ${targetDir}..." >&2
                #
                #                     # Clean up old style symlinks
                #                     if [ -e "${targetDir}" ] && [ -L "${targetDir}" ]; then
                #                       rm "${targetDir}"
                #                     fi
                #                     mkdir -p "${targetDir}"
                #
                #                     rsyncFlags=(
                #                       --checksum
                #                       --copy-unsafe-links
                #                       --archive
                #                       --delete
                #                       --no-times
                #                       --chmod=-w
                #                       --no-group
                #                       --no-owner
                #                       --exclude='*.localized'
                #                       --exclude='Icon?'
                #                     )
                #                     ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" ${homeApps}/Applications/ "${targetDir}"
                #                 '';
                #         })
                #     ];
                # }

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
                            inputs.sops-nix.homeManagerModules.sops
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
                            inputs.nixkit.nixosModules.default
                        ];
                    }
                )
            ]
            ++ lib.optionals pkgs.stdenv.isLinux [
                inputs.determinate.nixosModules.default
            ];
    }
