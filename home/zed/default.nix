_: {
  programs.zed-editor = {
    enable = true;
    extensions = ["swift" "nix" "xy-zed" "catppuccin" "docker compose" "catppuccin icons"];
    userSettings = {
      features = {
        copilot = false;
      };
      telemetry = {
        metrics = false;
        diagnostics = false;
      };
      vim_mode = true;
      ui_font_size = 12;
      buffer_font_size = 12;
      buffer_font_family = "JetBrains Mono";
      ui_font_family = "JetBrains Mono";
      tab_size = 4;
      theme = {
        mode = "system";
        light = "Catppuccin Mocha";
        dark = "Catpuccin Mocha";
      };
      icon_theme = "Catppuccin Mocha";
      terminal = {
        font_family = "JetBrains Mono";
        toolbar = {
          title = false;
        };
        shell = {
          program = "zsh";
        };
        copy_on_select = true;
      };
    };
  };
}
