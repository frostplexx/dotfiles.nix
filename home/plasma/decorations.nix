_: {
  programs.plasma = {
    workspace = {
      windowDecorations.library = "org.kde.breeze"; # The library for the window decorations theme. To see available values see the library key in the org.kde.kdecoration2 section of ~/.config/kwinrc after applying the window-decoration via the settings app.
      windowDecorations.theme = "Breeze"; # The window decorations theme. To see available values see the theme key in the org.kde.kdecoration2 section of ~/.config/kwinrc after applying the window-decoration via the settings app.
    };

    configFile = {
      "kwinrc" = {
        "org.kde.kdecoration2"."ButtonsOnLeft" = "SF";
      };
    };
  };
}
