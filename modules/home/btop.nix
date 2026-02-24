_: {
  flake.modules.homeManager.btop = _: {
    # Download the btop catppuccin theme
    xdg.configFile = {
      #Btop theme
      "btop/themes/catppuccin-mocha.theme" = {
        source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/catppuccin_mocha.theme";
          sha256 = "0i263xwkkv8zgr71w13dnq6cv10bkiya7b06yqgjqa6skfmnjx2c";
        };
      };
    };

    programs.btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin-mocha";
        theme_background = false;
        # This causes problems or something
        vim_keys = false;
        update_ms = 700;
      };
    };
  };
}
