{pkgs, ...}: {
  dconf = {
    enable = true;
    settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          gsconnect.extensionUuid
          just-perfection.extensionUuid
          dock-from-dash.extensionUuid
          space-bar.extensionUuid
          # forge.extensionUuid # Tiling window manager for gnome
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        text-scaling-factor = 0.9;
      };
    };
  };
}
