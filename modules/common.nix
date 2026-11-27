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
  # Both hosts take tack from the gh:manic-systems/tack pin. The nixpkgs
  # release lags and its resolver cannot read groups, omit_inputs or frozen.
  flake.darwinModules.common = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [common];
    # tack has no nix-darwin module; its NixOS module only adds the package.
    environment.systemPackages = [inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.tack];
  };

  flake.nixOSModules.common = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [common];
    programs.tack = {
      enable = true;
      package = inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.tack;
    };
  };
}
