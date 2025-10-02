{pkgs, ...}:
{
  programs.sketchybar = {
    enable = true;
    configType = "lua";
    extraPackages = with pkgs; [
      lua
      jq
      sbarlua
    ];
    config = {
        source = ./config;
        recursive = true;
    };
  };


  home.file = {
    ".local/share/sketchybar_lua/sketchybar.so" = {
        source = "${pkgs.sbarlua}/lib/lua/5.4/sketchybar.so";
        onChange = "${pkgs.sketchybar}/bin/sketchybar --reload";
      };
  };
}
