{pkgs, ...}: let
    connectionScript =
        pkgs.writeShellScriptBin "script" ''
        '';
    disconnectionScript =
        pkgs.writeShellScriptBin "script" ''
        '';
in {
    security.sudo.extraRules = [
        {
            users = ["sunshine" "daniel" "root"];
            commands = [
                {
                    command = "${pkgs.kbd}/bin/chvt";
                    options = ["NOPASSWD"];
                }
            ];
        }
    ];
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
                        # image-path = "${image}";
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
