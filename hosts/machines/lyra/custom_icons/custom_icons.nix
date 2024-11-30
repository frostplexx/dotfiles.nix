{
  pkgs,
  config,
  ...
}: {
  environment.customIcons = {
    enable = true;
    clearCacheOnActivation = true; # Optional
    icons = [
      {
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Spotify.app";
        icon = ./spotify.icns;
      }
      {
        path = "${pkgs.kitty}/Applications/kitty.app";
        icon = ../../../../home/programs/kitty/kitty.app.png;
      }
      # {
      #   path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Firefox.app";
      #   icon = ./firefox.icns;
      # }
      # {
      #   path = "/Applications/Things3.app";
      #   icon = ./things.icns;
      # }
      {
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Vesktop.app";
        icon = ./discord.icns;
      }
    ];
  };
}
