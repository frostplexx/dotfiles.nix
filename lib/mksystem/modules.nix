{ inputs, pkgs, nixpkgsConfig, system, user, name, machineConfig, machineConfigArgs, hm-modules, assets, mkHomeConfig }:
let
  inherit (pkgs.stdenv) isDarwin;
  home-manager =
    if isDarwin
    then inputs.home-manager.darwinModules
    else inputs.home-manager.nixosModules;
  darwinModule = import ./darwin.nix { inherit inputs user; };
  linuxModule = import ./linux.nix { inherit inputs; };
in
[
  { nixpkgs.overlays = pkgs.overlays or []; }
  { nixpkgs.config = nixpkgsConfig; }
  ({ modulesPath, ... }: import machineConfig (machineConfigArgs // { inherit modulesPath; }))
  ({ pkgs, ... }: import ../../scripts/jinx { inherit pkgs; })
  { nix.settings.trusted-users = ["root" user]; }
  home-manager.home-manager
  {
    nixpkgs.config = nixpkgsConfig;
    system.stateVersion =
      if isDarwin
      then 6
      else "24.05";
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs system assets; };
      sharedModules = [
        inputs.nixcord.homeModules.nixcord
        inputs._1password-shell-plugins.hmModules.default
        inputs.nixkit.homeModules.default
        inputs.sops-nix.homeManagerModules.sops
        inputs.spicetify-nix.homeManagerModules.spicetify
        inputs.mac-app-util.homeManagerModules.default
      ];
      users.${user} = mkHomeConfig {
        inherit user;
        modules = hm-modules;
      };
    };
  }
  {
    config._module.args = {
      currentSystem = system;
      currentSystemName = name;
      currentSystemUser = user;
      inherit user system inputs assets;
    };
  }
  (if isDarwin then darwinModule else linuxModule)
]
++ pkgs.lib.optionals pkgs.stdenv.isLinux [
  inputs.determinate.nixosModules.default
]
