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
      ui_font_size = 13;
      buffer_font_size = 12;
      buffer_font_family = "Maple Mono NF";
      ui_font_family = "Maple Mono";
      tab_size = 4;
      theme = {
        mode = "system";
        light = "Catppuccin Mocha";
        dark = "Catpuccin Mocha";
      };
      icon_theme = "Catppuccin Mocha";
      terminal = {
        font_family = "Maple Mono NF";
        toolbar = {
          title = false;
        };
        shell = {
          program = "fish";
        };
        copy_on_select = true;
      };
    };
  };
}
