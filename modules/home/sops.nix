_: {
  flake.homeManagerModules.sops = {config, ...}: {
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    };
  };
}
