{ pkgs, ... }:
{
  environment.customIcons = {
    enable = true;
    icons = [
      {
        path = "/${pkgs.spotify}/Applications/Spotify.app";
        icon = ./spotify.icns;
      }
      {
        path = "${pkgs.vesktop}/Applications/Vesktop.app";
        icon = ./discord.icns;
      }
    ];
  };
}
