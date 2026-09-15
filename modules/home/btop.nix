_: {
  flake.homeManagerModules.btop = {inputs, ...}: {
    # Download the btop catppuccin theme
    xdg.configFile = {
      #Btop theme
      "btop/themes/catppuccin-mocha.theme" = {
        source = "${inputs.catppuccin-btop}/themes/catppuccin_mocha.theme";
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
