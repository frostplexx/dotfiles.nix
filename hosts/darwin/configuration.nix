{...}: {
  imports = [
    ./apps.nix
    ./system.nix
    ./host-users.nix
    ./custom_icons/custom_icons.nix
    ./stylix.nix
    ./yabai
  ];

  services.nix-daemon.enable = true;
}
