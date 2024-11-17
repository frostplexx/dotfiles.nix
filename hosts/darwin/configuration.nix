{ pkgs,vars, ... }:
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
    package = pkgs.nixVersions.git;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    optimise.automatic = true;
    settings = {
      trusted-users = [vars.user];
    };
  };

}
