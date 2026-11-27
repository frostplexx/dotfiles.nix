_: let
  common = {
    pkgs,
    defaults,
    ...
  }: {
    time.timeZone = defaults.system.timeZone;

    environment = {
      pathsToLink = ["/share/fish"];
      shells = [pkgs.fish];
    };

    programs = {
      fish.enable = true;
      _1password.enable = true;
      _1password-gui.enable = true;
    };

    fonts.packages = with pkgs; [maple-mono.NF];

    home-manager.users.${defaults.user} = {
      home = {
        username = defaults.user;
        sessionVariables.EDITOR = "nvim";
      };
      programs.home-manager.enable = true;
    };
  };
in {
  flake.darwinModules.common = {pkgs, ...}: {
    imports = [common];
    # tack has no nix-darwin module; its NixOS module only adds the package.
    environment.systemPackages = [pkgs.tack];
  };

  flake.nixOSModules.common = {
    imports = [common];
    programs.tack.enable = true;
  };
}
