{
  inputs,
  pkgs,
  ...
}: {
  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      shuffle # shuffle+ (special characters are sanitized out of extension names)
      playlistIcons
      goToSong
    ];

    # Pull the theme directly from the spicetify-themes repo because the nixpkgs is a bit out of date
    theme = spicePkgs.themes.text;
    colorScheme = "CatppuccinMocha";
  };
}
