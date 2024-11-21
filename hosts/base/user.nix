# Base user configuration for both NixOS and Darwin
{
  vars,
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (pkgs.stdenv) isDarwin;
  inherit (pkgs.stdenv) isLinux;
in {
  options.user = {
    name = mkOption {
      type = types.str;
      default = vars.user;
      description = "Primary user name";
    };
  };

  config = {
    # User configuration for NixOS
    users = lib.mkMerge [
      # Common user settings
      {
        users.${config.user.name} = {
          description = config.user.name;
        };
      }

      # Linux-specific settings
      (lib.mkIf isLinux {
        users.${config.user.name} = {
          isNormalUser = true;
          home = "/home/${config.user.name}";
          extraGroups = ["wheel"];
          shell = pkgs.zsh;
        };
      })

      # Darwin-specific settings
      (lib.mkIf isDarwin {
        users.${config.user.name} = {
          home = "/Users/${config.user.name}";
          shell = pkgs.zsh;
        };
      })
    ];

    # Configure home-manager for the user
    home-manager.users.${config.user.name} = {
      home = {
        username = config.user.name;
        homeDirectory =
          if isDarwin
          then "/Users/${config.user.name}"
          else "/home/${config.user.name}";
      };
    };

    # Set default shell for all users
    programs.zsh.enable = true;
    nix.settings.trusted-users = [config.user.name];
  };
}
