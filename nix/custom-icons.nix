# custom-icons.nix
# A NixOS module for customizing macOS folder/file icons
#
# Usage in your configuration.nix or home-manager config:
#
# imports = [
#   ./custom-icons.nix  # Adjust path as needed
# ];
#
# environment.customIcons = {
#   enable = true;
#   clearCacheOnActivation = true;  # Optional: clear icon cache on activation
#   icons = [
#     {
#       path = "/Applications/Firefox.app";  # Path to file/folder to customize
#       icon = ./path/to/icon.icns;         # Path to .icns file
#     }
#     # Add more icon configurations as needed
#   ];
# };
{
  lib,
  config,
  ...
}: let
  cfg = config.environment.customIcons;
  inherit
    (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;
in {
  options.environment.customIcons = {
    enable = mkEnableOption "environment.customIcons";
    clearCacheOnActivation = mkEnableOption "environment.customIcons.clearCacheOnActivation";
    icons = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            path = mkOption {
              type = types.path;
              description = "Path to the file or folder to customize";
            };
            icon = mkOption {
              type = types.path;
              description = "Path to the .icns file to use as the custom icon";
            };
          };
        }
      );
      description = "List of icon configurations to apply";
      default = [];
      example = [
        {
          path = "/Applications/Firefox.app";
          icon = ./icons/firefox.icns;
        }
      ];
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      system.activationScripts.extraActivation.text = ''
        echo -e "applying custom icons..."
        ${
          (builtins.concatStringsSep "\n\n" (
            builtins.map (iconCfg: ''
              osascript <<EOF >/dev/null
                use framework "Cocoa"
                set iconPath to "${iconCfg.icon}"
                set destPath to "${iconCfg.path}"
                set imageData to (current application's NSImage's alloc()'s initWithContentsOfFile:iconPath)
                (current application's NSWorkspace's sharedWorkspace()'s setIcon:imageData forFile:destPath options:2)
              EOF
            '')
            cfg.icons
          ))
        }
        ${lib.optionalString cfg.clearCacheOnActivation ''
          sudo rm -rf /Library/Caches/com.apple.iconservices.store
          sudo find /private/var/folders/ -name com.apple.dock.iconcache -or -name com.apple.iconservices -or -name com.apple.iconservicesagent -exec rm -rf {} \; || true
          killall Dock
        ''}'';
    })
  ];
}
