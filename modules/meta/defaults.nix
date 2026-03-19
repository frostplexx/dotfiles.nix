{lib, ...}: {
    options.flake.defaults = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Shared default values passed to all configurations via specialArgs";
    };

    config.flake.defaults = {
        user = "daniel";

        system = {
            darwinVersion = 6;
            nixosVersion = "25.11";
            timeZone = "Europe/Berlin";
            locale = "en_US.UTF-8";
        };

        settings = {
            wallpaper = builtins.fetchurl {
                url = "https://media.githubusercontent.com/media/frostplexx/dotfiles-assets.nix/refs/heads/main/wallpapers/wallpaper.jpg";
                sha256 = "09q9w5x6i625wavj39g25lrnap4ak7m1mp15yyjdrbj2n1pzsi3f";
            };

            accent_color = "cba6f7";
            transparent_terminal = false;
        };

        personalInfo = {
            name = "Daniel";
            email = "62436912+frostplexx@users.noreply.github.com";
            signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC6vBvnnlbxJXg9lUqFD0mil+60y4BZr/UAcX1Y4scV";
        };

        paths = {
            flake = "~/dotfiles.nix";
        };
    };
}
