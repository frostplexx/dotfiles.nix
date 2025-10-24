{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.smbAutoMount;

  autoDirectContent = concatStringsSep "\n" (
    mapAttrsToList (
      mountPoint: mountConfig: "${mountPoint} -fstype=smbfs,${concatStringsSep "," mountConfig.options} ${mountConfig.share}"
    )
    cfg.mounts
  );

  triggerScript = concatStringsSep "\n" (
    [
      ''
        echo "Triggering SMB automounts..."
        sleep 3
      ''
    ]
    ++ (mapAttrsToList (mountPoint: _: ''
        echo "Triggering automount for ${mountPoint}..."
        ls "${mountPoint}" >/dev/null 2>&1 || true
      '')
      cfg.mounts)
    ++ ["echo \"Mount triggering complete!\""]
  );

  finderScript = concatStringsSep "\n" (
    [
      ''
        echo "Adding SMB mounts to Finder sidebar..."
        add_to_sidebar() {
          local mount_path="$1"
          local alias_name="$2"

          if [[ ! -d "$mount_path" ]]; then
            echo "Creating mount point $mount_path..."
            mkdir -p "$mount_path" || {
              echo "Failed to create mount point $mount_path"
              return 1
            }
          fi

          /usr/bin/osascript -e "
            tell application \\"Finder\\"
              try
                make new alias file at desktop to folder POSIX file \\"$mount_path\\"
                set name of result to \\"$alias_name\\"
              end try
            end tell
          " 2>/dev/null || true

          if command -v sfltool &>/dev/null; then
            sfltool add-item com.apple.LSSharedFileList.FavoriteVolumes file://$mount_path 2>/dev/null || true
          fi
        }
      ''
    ]
    ++ (mapAttrsToList (
        mountPoint: mountConfig: ''add_to_sidebar "${mountPoint}" "${mountConfig.sidebarName or (baseNameOf mountPoint)}"''
      )
      cfg.mounts)
  );
in {
  options.services.smbAutoMount = {
    enable = mkEnableOption "SMB automounting with Finder sidebar integration";

    mounts = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          share = mkOption {
            type = types.str;
            description = "SMB share URL (e.g., //user:pass@server/share)";
          };

          options = mkOption {
            type = types.listOf types.str;
            default = ["rw" "noauto" "soft" "noowners" "nosuid"];
            description = "Mount options";
          };

          sidebarName = mkOption {
            type = types.str;
            default = "";
            description = "Name to display in Finder sidebar (defaults to basename of mount point)";
          };
        };
      });
      default = {};
      description = "SMB shares to automount";
    };

    autoSetup = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to automatically setup mounts and add to Finder sidebar on activation";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."auto_direct" = mkIf (cfg.mounts != {}) {
      text = autoDirectContent;
    };

    system.activationScripts.smbAutoMount = mkIf cfg.autoSetup {
      text = ''
        echo "Setting up SMB automounts..."

        ${concatStringsSep "\n" (mapAttrsToList (mountPoint: _: ''
            echo "Creating mount directory ${mountPoint}..."
            mkdir -p "${mountPoint}" || true
            chmod 755 "${mountPoint}" || true
          '')
          cfg.mounts)}

        if [ -f /etc/auto_master ] && [ ! -f /etc/auto_master.backup ]; then
          cp /etc/auto_master /etc/auto_master.backup
        fi

        if [ -f /etc/auto_master ] && ! grep -q "^/-.*auto_direct" /etc/auto_master; then
          echo "/-    auto_direct" >> /etc/auto_master
          echo "Added auto_direct to /etc/auto_master"
        fi

        echo "SMB automount setup complete!"
      '';
    };

    launchd.user.agents.smbAutoMount = mkIf (cfg.mounts != {} && cfg.autoSetup) {
      serviceConfig = {
        Label = "com.nix.smb-automount";
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          ''
            sleep 5
            /usr/sbin/automount -vc
            sleep 3
            ${triggerScript}
          ''
        ];
        RunAtLoad = true;
        StandardOutPath = "/tmp/smb-automount.log";
        StandardErrorPath = "/tmp/smb-automount.log";
      };
    };

    launchd.user.agents.smbFinderSidebar = mkIf (cfg.mounts != {} && cfg.autoSetup) {
      serviceConfig = {
        Label = "com.nix.smb-finder-sidebar";
        ProgramArguments = [
          "${pkgs.bash}/bin/bash"
          "-c"
          finderScript
        ];
        RunAtLoad = true;
        StartInterval = 30;
        StandardOutPath = "/tmp/smb-finder-sidebar.log";
        StandardErrorPath = "/tmp/smb-finder-sidebar.log";
      };
    };
  };
}
