_: {
  xdg.configFile = {
    "ghostty/config" = {
      source = ./config;
      recursive = true;
    };
  };
  programs.zellij = {
    enable = false;
    enableFishIntegration = true;
    settings = {
      theme = "catppuccin-macchiato";
    };
  };
}
