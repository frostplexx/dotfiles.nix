_: {
  flake.homeManagerModules.obsidian = {pkgs, ...}: {
    programs.obsidian = {
      enable = true;
      cli.enable = true;
      vaults = {
        "Memex" = {
          enable = true;
          target = "Documents";
        };
      };
    };

    home.file."Documents/Memex/.claude" = {
      source = ./claude_config;
      recursive = true;
    };

    home.file."Documents/Memex/.claude/claude" = {
      source = "${pkgs.claude-code}/bin/claude";
      executable = true;
    };
  };
}
