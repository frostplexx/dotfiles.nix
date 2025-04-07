{
  config,
  pkgs,
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
        path = "${pkgs.spotify}/Applications/Spotify.app";
        icon = ./spotify.icns;
      }
      # {
      #   path = "${pkgs.kitty}/Applications/kitty.app";
      #   icon = ../../../../home/programs/kitty/kitty.app.png;
      # }
      {
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Vesktop.app";
        icon = ./discord.icns;
      }
      {
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/WezTerm.app";
        icon = ./wezterm.icns;
      }
    ];
  };
}
