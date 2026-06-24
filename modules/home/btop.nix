_: {
  flake.homeManagerModules.btop = {defaults, ...}: {
    # Download the btop catppuccin theme
    xdg.configFile = {
      #Btop theme
      "btop/themes/catppuccin-mocha.theme" = {
        source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/btop/refs/heads/main/themes/catppuccin_mocha.theme";
          sha256 = "0i263xwkkv8zgr71w13dnq6cv10bkiya7b06yqgjqa6skfmnjx2c";
        };
      };

      "btop/themes/rose-pine.theme" = {
        source = builtins.fetchurl {
          url = "https://raw.githubusercontent.com/rose-pine/btop/refs/heads/main/rose-pine.theme";
          sha256 = "1injry07mx683f1cy2ks73rdiv4dfi8b5ija8bq6adhbgcw7b1h8";
        };
      };
    };

    programs.btop = {
      enable = true;
      settings = {
        color_theme =
          {
            "catppuccin" = "catppuccin-mocha";
            "rose-pine" = "rose-pine";
          }
            .${
            defaults.settings.theme
          };
        theme_background = false;
        # This causes problems or something
        vim_keys = false;
        update_ms = 700;
      };
    };
  };
}
