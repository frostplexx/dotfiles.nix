{pkgs, ...}:
{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    extraPackages = with pkgs; [
      lua
      jq
      sbarlua
      aerospace
      nowplaying-cli
      switchaudio-osx
    ];
    service = {
      enable = true;
      errorLogFile = /tmp/sketchyerr;
      outLogFile = /tmp/sketchylog;
    };
    config = {
        source = ./config;
        recursive = true;
    };
  };

}
