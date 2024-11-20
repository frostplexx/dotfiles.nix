# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  pkgs,
  inputs,
  nixpkgs,
  home-manager,
  vars,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./system.nix
    ./apps.nix
    ./users.nix
    ./stylix.nix
  ];

  # Your existing nixosConfigurations and darwinConfigurations stay the same
  nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = {inherit vars inputs;};
    modules = [
      ./nix/core.nix
      inputs.yuki.nixosModules.default
      ./hosts/nixos/configuration.nix
      inputs.stylix.nixosModules.stylix
      home-manager.nixosModules.home-manager
      {
        nixpkgs.overlays = [inputs.nur.overlay];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {inherit vars inputs;};
          users.${vars.user} = import ./home;
          sharedModules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager
            inputs.nixcord.homeManagerModules.nixcord
            inputs.spicetify-nix.homeManagerModules.default
            {
              # explicitly disable stylix for spicetify because its managed by spicetify-nix
              # TODO: This is a stupid place to put this and needs to be refactored
              stylix.targets.spicetify.enable = false;
            }
          ];
        };
      }
    ];
  };

  # Set shell for all users
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Automatic System Upgradesconfixg
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "--print-build-logs"
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [22];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
