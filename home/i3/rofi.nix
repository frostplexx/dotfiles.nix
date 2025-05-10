{pkgs, ...}: {
    programs.rofi = {
        enable = true;
        font = "Maple Mono NF";
        plugins = [
            pkgs.rofi-calc
        ];
        theme = "catppuccin-default";
        terminal = "${pkgs.kitty}/bin/kitty";
    };

    xdg.configFile = {
        "rofi/catppuccin-mocha.rasi".source = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/rofi/refs/heads/main/themes/catppuccin-mocha.rasi";
            sha256 = "0mdg3kmszkdr50n4c69p6xkf7ilh57h39hp4nwbfzyfm6wn89rza";
        };

        "rofi/catppuccin-default.rasi".source = builtins.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/rofi/refs/heads/main/catppuccin-default.rasi";
            sha256 = "1lwzc71cdb7nd0qmmdnnkr512rdj6xk62mx260m049wi1vlg5pdv";
        };
    };
}
