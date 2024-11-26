{
  pkgs,
  config,
  ...
}: {
  environment.customIcons = {
    enable = true;
    icons = [
      {
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Spotify.app";
        icon = ./spotify.icns;
      }
      {
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Firefox.app";
        icon = ./firefox.icns;
      }
      {
        path = "/Applications/Things3.app";
        icon = ./things.icns;
      }
      {
        path = "${pkgs.vesktop}/Applications/Vesktop.app";
        icon = ./discord.icns;
      }
    ];
  };
}
