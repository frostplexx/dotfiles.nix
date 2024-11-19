{
  pkgs,
  config,
  ...
}: {
  environment.customIcons = {
    enable = true;
    icons = [
      {
        # Use proper path concatenation for home directory
        path = "${config.users.users.daniel.home}/Applications/Home Manager Apps/Spotify.app";
        icon = ./spotify.icns;
      }
      {
        path = "${pkgs.vesktop}/Applications/Vesktop.app";
        icon = ./discord.icns;
      }
    ];
  };
}
