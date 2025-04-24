{
    config,
    lib,
    pkgs,
    ...
}: {
    config = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        system.activationScripts.hardlinkNixApps = {
            text = ''
                # Create hardlinks for Nix applications to make them indexable by Spotlight
                echo "Creating hardlinks for Nix applications in ${config.nix.app-hardlinks.directory}..."

                TARGET_DIR="${config.nix.app-hardlinks.directory}"
                NIX_STORE_APPS=$(find -L /nix/store -path "*/Applications/*.app" -type d 2>/dev/null)
                NIX_PROFILE_APPS=$(find -L /run/current-system/sw/Applications -name "*.app" -type d 2>/dev/null)
                LOCAL_PROFILE_APPS=$(find -L $HOME/.nix-profile/Applications -name "*.app" -type d 2>/dev/null 2>/dev/null)

                # Create target directory if it doesn't exist
                mkdir -p "$TARGET_DIR"

                # Function to create hardlinks recursively
                create_hardlinks() {
                    local source="$1"
                    local target="$2"

                    # Create target directory if it doesn't exist
                    mkdir -p "$target"

                    # Iterate through all files in the source directory
                    for item in "$source"/*; do
                        [ -e "$item" ] || continue  # Skip if the item doesn't exist

                        local basename=$(basename "$item")
                        local target_item="$target/$basename"

                        # If directory, recurse
                        if [ -d "$item" ] && [ ! -L "$item" ]; then
                            mkdir -p "$target_item"
                            create_hardlinks "$item" "$target_item"
                        # If file or symlink to file, create hardlink
                        elif [ -f "$item" ] || [ -L "$item" ]; then
                            # Get the real file (resolve symlink if needed)
                            local real_file=$(readlink -f "$item" 2>/dev/null)
                            if [ -z "$real_file" ]; then
                                real_file="$item"  # If readlink fails, use original path
                            fi

                            # Only create hardlink if the source is a regular file
                            if [ -f "$real_file" ]; then
                                ln -f "$real_file" "$target_item" 2>/dev/null || \
                                cp -f "$real_file" "$target_item" 2>/dev/null  # Fallback to copy if hardlink fails
                            fi
                        fi
                    done
                }

                # Process all application bundles
                process_app() {
                    local app_path="$1"
                    local app_name=$(basename "$app_path")
                    local target_app="$TARGET_DIR/$app_name"

                    # Remove existing application bundle if it exists
                    if [ -d "$target_app" ]; then
                        rm -rf "$target_app"
                    fi

                    mkdir -p "$target_app"
                    create_hardlinks "$app_path" "$target_app"

                    # Set proper macOS bundle attributes
                    xattr -rd com.apple.quarantine "$target_app" 2>/dev/null || true
                    touch "$target_app"  # Update timestamp to force Spotlight reindexing
                }

                # Process all found applications
                for app in $NIX_STORE_APPS $NIX_PROFILE_APPS $LOCAL_PROFILE_APPS; do
                    process_app "$app"
                done

                # Clean up old applications that no longer exist in Nix
                for existing_app in "$TARGET_DIR"/*.app; do
                    [ -e "$existing_app" ] || continue  # Skip if not exists

                    app_name=$(basename "$existing_app")
                    found=0

                    # Check if app still exists in any Nix location
                    for app in $NIX_STORE_APPS $NIX_PROFILE_APPS $LOCAL_PROFILE_APPS; do
                        if [ "$(basename "$app")" = "$app_name" ]; then
                            found=1
                            break
                        fi
                    done

                    # Remove app if it no longer exists in Nix
                    if [ $found -eq 0 ]; then
                        echo "Removing obsolete app: $app_name"
                        rm -rf "$existing_app"
                    fi
                done

                # Force Spotlight to re-index the directory
                mdimport "$TARGET_DIR" 2>/dev/null || true
                echo "Hardlinking of Nix applications complete"
            '';
            deps = [];
        };
    };

    options.nix.app-hardlinks = {
        enable = lib.mkEnableOption "Create hardlinks to Nix applications for Spotlight indexing";

        directory = lib.mkOption {
            type = lib.types.str;
            default = "/Applications/Nix Apps";
            description = "Directory where application bundles will be hardlinked";
        };
    };
}
