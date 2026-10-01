_: {
  flake.homeManagerModules.nh = {
    config,
    defaults,
    ...
  }: {
    # Sets NH_FLAKE so plain `nh darwin switch` / `nh os switch` find the repo.
    programs.nh = {
      enable = true;
      flake = "${config.home.homeDirectory}/${defaults.paths.flake}";
    };
  };
}
