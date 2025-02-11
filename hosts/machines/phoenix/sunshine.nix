{pkgs, ...}: let
  image = builtins.fetchurl {
    url = "https://cdn.osxdaily.com/wp-content/uploads/2017/12/classic-mac-os-tile-wallpapers-4.png";
    sha256 = "sha256-nxf5bxpNI2j+K0+T3B6zxP5aGk05Y/FDEZSSQ1ESxtU=";
  };
  connectionScript = pkgs.writeShellScriptBin "script" ''
    export DISPLAY=:0
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 1920x1080 --rate 144
  '';
  disconnectionScript = pkgs.writeShellScriptBin "script" ''
    export DISPLAY=:0
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1080 --rate 144
  '';
  steamImage = builtins.fetchurl {
    url = "https://cdn2.steamgriddb.com/grid/39c2966989c4f0091a99eef7f1d09c09.png";
    sha256 = "sha256-YZmRA0mMU6Ez6PxskyNasCspGRMeduh+L7JzZ5NQE6I=";
  };
in {
  services = {
    sunshine = {
      enable = true;
      openFirewall = true;
      capSysAdmin = true;
      settings = {
        sunshine_name = "❄️NixOS❄️";
        output_name = 1;
        resolutions = "[ 2560x1080 1920x1080 ]";
        fps = "[ 120 144 ]";
        nvenc_preset = 1;
      };
      applications = {
        apps = [
          {
            name = "Desktop";
            image-path = "${image}";
            prep-cmd = [
              {
                do = "${connectionScript}/bin/script";
                undo = "${disconnectionScript}/bin/script";
              }
            ];
            exclude-global-prep-cmd = "false";
            auto-detach = "true";
          }
          {
            name = "Steam Big Picture";
            image-path = "${steamImage}";
            cmd = "${pkgs.steam}/bin/steam -bigpicture";
            prep-cmd = [
              {
                do = "${connectionScript}/bin/script";
                undo = "${disconnectionScript}/bin/script";
              }
            ];
            exclude-global-prep-cmd = "false";
            auto-detach = "true";
            detached = ["${pkgs.steam}/bin/steam"];
          }
        ];
      };
    };
  };
}
