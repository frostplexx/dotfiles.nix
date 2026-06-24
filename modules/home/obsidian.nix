_: {
  flake.homeManagerModules.lazygit = {
    lib,
    pkgs,
    ...
  }: {
    programs.obsidian = {
      enable = true;
      cli.enable = true;
      vaults = {
        "Memex" = {
          enabled = true;
          path = "Documents";
        };
      };
      defaultSettings = {
        extraFiles = {
          "claude" = {
            source = lib.getExe pkgs.claude-code;
            target = "claude";
          };
        };
      };
    };
  };
}
