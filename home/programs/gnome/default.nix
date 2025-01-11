{pkgs, ...}: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          just-perfection.extensionUuid
          space-bar.extensionUuid
          tactile.extensionUuid
          undecorate.extensionUuid
          user-themes.extensionUuid
          appindicator.extensionUuid
          # status-icons.extensionUuid
        ];
      };

      "org/gnome/mutter" = {
        experimental-features = ["scale-monitor-framebuffer"];
        edge-tiling = true;
        center-new-windows = true;
      };

      "org/gnome/desktop/background" = {
        picture-uri = "file://${../plasma/wallpaper.png}";
        picture-uri-dark = "file://${../plasma/wallpaper.png}";
        picture-options = "zoom";
      };

      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${../plasma/wallpaper.png}";
        picture-uri-dark = "file://${../plasma/wallpaper.png}";
        picture-options = "zoom";
      };
    };
  };
}
