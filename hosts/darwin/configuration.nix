{ ... }:
{
  imports =
    [
      ./apps.nix
      ./system.nix
      ./host-users.nix
      ./custom_icons/custom_icons.nix
      ./stylix.nix
    ];
  services.nix-daemon.enable = true;
  # TODO: make this shared between darwin and nixos
  nix = {
    optimise.automatic = true;
    # Optional but recommended: Keep build dependencies around for offline builds
    settings.keep-outputs = true;
    settings.keep-derivations = true;
  };

}
