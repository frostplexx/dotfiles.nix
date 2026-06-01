_: {
  flake.homeManagerModules.raycast = _: {
    # Raycast configuration using nixkit module
    programs.raycast = {
      enable = true;
      configFile = ./config.json;
    };
  };
}
