{pkgs, ...}: {
  # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };

    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };

    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

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
          user-themes.extensionUuid
        ];

        favorite-apps = [
          "zen.desktop"
          "kitty.desktop"
          "1password.desktop"
          "steam.desktop"
          "spotify.desktop"
          "vesktop.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      "org/gnome/desktop/interface" = {
        enable-hot-corners = false;
        text-scaling-factor = 0.85;
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
