# Source: https://github.com/joneshf/home-manager/blob/main/modules/targets/darwin/copy-application-bundles/module.nix
{
    config,
    lib,
    pkgs,
    ...
}: {
    config = lib.modules.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        home = {
            file = {
                ${config.targets.darwin.copy-application-bundles.directory} = {
                    # Setting `recursive = true` means that we get the structure we require:
                    # - This will create the actual `"Applications/Copied Application Bundles"` directory as a real directory.
                    # - Inside it will create the actual Application Bundles as real directories.
                    # - Everything inside the Application Bundles will be a symlink.
                    recursive = true;

                    source = let
                        # This is what `home-manager` does to create `~/Applications/Home Manager Apps`:
                        # https://github.com/nix-community/home-manager/blob/b4e98224ad1336751a2ac7493967a4c9f6d9cb3f/modules/targets/darwin/linkapps.nix#L6-L12.
                        application-bundle-symlinks = pkgs.buildEnv {
                            name = "application-bundle-symlinks";
                            paths = config.home.packages;
                            pathsToLink = "/Applications";
                        };
                    in
                        # We then create actual directories for each Application Bundle,
                        # so Spotlight, the Dock, and other things will work like normal.
                        # Inside of those actual Application Bundle directories we put symlinks to everything in the actual Application Bundle.
                        # It seems that things like Spotlight don't actually care what's inside of the Application Bundle,
                        # so long as it's a real directory.
                        #
                        # This pattern was originally suggested in: https://github.com/hraban/mac-app-util/issues/27.
                        #
                        # Hopefully this can be fixed in Home Manager proper,
                        # then we wouldn't have to do any of this.
                        pkgs.runCommand "copy-application-bundles" {} ''
                            mkdir $out

                            symlinkedApplicationsDirectory=${application-bundle-symlinks}/Applications
                            # Find the first level of Application Bundles no matter how deeply they are nested.
                            # This should find Application Bundles like:
                            # - `/nix/store/abc123-foo/Applications/Some Application.app`
                            # - `/nix/store/abc123-foo/Applications/some/nested/Application.app`
                            #
                            # But not Application Bundles nested inside another Application Bundle:
                            # - `/nix/store/abc123-foo/Applications/Some Application.app/Contents/Frameworks/AnotherApplication.app`
                            shopt -s globstar
                            for applicationBundleSymlink in "$symlinkedApplicationsDirectory"/**/*.app; do
                              # Remove the prefix of the `applicationBundleSymlink`.
                              # This should make transformations like:
                              # - `/nix/store/abc123-foo/Applications/Some Application.app` -> `Some Application.app`
                              # - `/nix/store/abc123-foo/Applications/some/nested/Application.app` -> `some/nested/Application.app`
                              applicationBundle="$out/''${applicationBundleSymlink#"$symlinkedApplicationsDirectory"/}"
                              mkdir --parents "$applicationBundle"
                              ln --symbolic "$applicationBundleSymlink"/* "$applicationBundle"
                            done
                            shopt -u globstar
                        '';
                };
            };
        };
    };

    disabledModules = [
        # We have to disable this module unconditionally,
        # since there isn't a way to do it at the `config` level.
        # Once https://github.com/nix-community/home-manager/pull/4809 is available on a release branch,
        # we can disable the module with `config`.
        #
        # Hopefully this whole thing gets fixed at some point,
        # so we don't have to maintain this module at all.
        "targets/darwin/linkapps.nix"
    ];

    options = {
        targets = {
            darwin = {
                copy-application-bundles = {
                    directory = lib.mkOption {
                        default = "Applications/Home Manager Apps";
                        description = "Directory to put the copied Application Bundles in.";
                        example = "Applications/Copied Application Bundles";
                        type = lib.types.str;
                    };
                };
            };
        };
    };
}
