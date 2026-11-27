_: {
  flake.homeManagerModules.sops = {config, ...}: {
    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      # modules/secrets.yaml, shared by every host. Whatever reads it exports
      # GITHUB_TOKEN itself; see the export in fish/shellInit.fish.
      defaultSopsFile = ../secrets.yaml;
      secrets."github-token" = {};
    };
  };
}
