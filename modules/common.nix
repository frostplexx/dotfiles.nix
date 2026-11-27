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
  # Every host collects self.darwinModules / self.nixOSModules, so both of these
  # reach the two configurations without an explicit import.
  flake.darwinModules.common = {imports = [common];};

  flake.nixOSModules.common = {imports = [common];};
}
