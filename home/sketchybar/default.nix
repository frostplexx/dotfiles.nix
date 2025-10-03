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
    luaPackage = pkgs.lua5_4;
    sbarLuaPackage = pkgs.sbarlua;
    config = {
        source = ./config;
        recursive = true;
    };
  };

}
