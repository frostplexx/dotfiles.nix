{pkgs, ...}: {
    # Nix settings import
    imports = [
        ./nix.nix
    ];

    # Add assets repo to config so its accessible everywhere
    assets = pkgs.fetchFromGitHub {
        owner = "frostplexx";
        repo = "dotfiles-assets.nix";
        rev = "05d9e391b72618a13934f1fdd6ef9a97e0ca296f";
        hash = "sha256-4MRo3b19fAVCY07sEN6AQGM6V4xiOO+UfVNGBIwwkGM=";
    };

    # Basic system packages
    environment.systemPackages = with pkgs; [
        # Development tools
        gnumake
        gcc
        entr # Run arbitrary commands when files change
        man-pages
        man-pages-posix
        #TODO: move to home manager: jq

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
        hcloud
        just

        nix-tree
        nix-output-monitor
        nh
        nvd

        # GUI applications
        obsidian
        _1password-cli
        transmission_4
        spotify
        imhex
    ];

    # Base fonts
    fonts.packages = with pkgs; [
        open-sans
        inter
        # Maple Mono (Ligature TTF hinted)
        maple-mono.truetype-autohint
        # Maple Mono NF (Ligature hinted)
        maple-mono.NF
    ];
}
