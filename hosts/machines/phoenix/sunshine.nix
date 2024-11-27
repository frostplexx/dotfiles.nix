{pkgs, ...}: let
  image = builtins.fetchurl {
    url = "https://cdn.osxdaily.com/wp-content/uploads/2017/12/classic-mac-os-tile-wallpapers-4.png";
    sha256 = "sha256:1mf6298l74ll251z2qrr9ld5mzn4ncgdr4sg5gz6h8sd39pzj5wz";
  };
  connectionScript = pkgs.writeShellScriptBin "script" ''
    export DISPLAY=:0
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 1920x1200 --rate 140
  '';
  disconnectionScript = pkgs.writeShellScriptBin "script" ''
    export DISPLAY=:0
    ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 1920x1200 --rate 144
  '';
in {
  services = {
    sunshine = {
      enable = true;
      openFirewall = true;
      capSysAdmin = true;
      settings = {
        sunshine_name = "❄️NixOS❄️";
        output_name = 1;
        resolutions = "[ 2560x1080 1920x1080 1920x1200 ]";
        fps = "[ 120 144 ]";
        encoder = "nvenc";
        nvenc_preset = 1;
        av1_mode = 1;
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
        ];
      };
    };
  };
}
