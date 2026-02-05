{inputs, ...}: {
    # Shared packages for both Darwin and NixOS
    # This module adds packages to both darwin and nixos configurations
    flake.modules.darwin.shared-packages = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
            # Development tools
            gnumake
            gcc
            entr
            man-pages
            man-pages-posix
            uv
            python3

            # CLI utilities
            ffmpeg
            imagemagick
            nmap
            pandoc
            ripgrep
            sshpass
            wget
            curl
            gnupg
            gh
            just
            jq
            magic-wormhole-rs
            netcat
            sops
            ghq
            termshark
            unp

            # Nix utils
            nix-tree
            nix-output-monitor
            nh
            nvd
            deadnix
            statix
            alejandra

            # GUI applications
            obsidian
            _1password-cli
            bvi

            inputs.determinate.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        documentation = {
            doc.enable = true;
            info.enable = true;
        };

        fonts.packages = with pkgs; [
            open-sans
            inter
            jetbrains-mono
            maple-mono.truetype-autohint
            maple-mono.NF
            sketchybar-app-font
        ];
    };

    flake.modules.nixos.shared-packages = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
            # Development tools
            gnumake
            gcc
            entr
            man-pages
            man-pages-posix
            uv
            python3

            # CLI utilities
            ffmpeg
            imagemagick
            nmap
            pandoc
            ripgrep
            sshpass
            wget
            curl
            gnupg
            gh
            just
            jq
            magic-wormhole-rs
            netcat
            sops
            ghq
            termshark
            unp

            # Nix utils
            nix-tree
            nix-output-monitor
            nh
            nvd
            deadnix
            statix
            alejandra

            # GUI applications
            obsidian
            _1password-cli
            bvi

            inputs.determinate.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];

        documentation = {
            doc.enable = true;
            info.enable = true;
        };

        fonts.packages = with pkgs; [
            open-sans
            inter
            jetbrains-mono
            maple-mono.truetype-autohint
            maple-mono.NF
            sketchybar-app-font
        ];
    };
}
