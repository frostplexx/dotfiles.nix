{inputs, ...}: let
  # Shared package configuration for both Darwin and NixOS
  mkSharedPackages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      # Development tools
      gnumake
      gcc
      entr
      man-pages
      man-pages-posix
      uv
      python

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
      inputs.tidaLuna.packages.${system}.default

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
in {
  flake.modules.darwin.shared-packages = mkSharedPackages;
  flake.modules.nixos.shared-packages = mkSharedPackages;
}
