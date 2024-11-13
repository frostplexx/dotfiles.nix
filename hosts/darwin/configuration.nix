{ inputs, ... }:
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


  # add a launch agent to ~/Library/LaunchAgents that periodically runs the update.sh script in this
  # repository
  services.launchd.agents.update = {
    enable = true;
    interval = "daily";
    command = "${inputs.dotfiles}/update.sh";
  };

}
