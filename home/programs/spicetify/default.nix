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
    theme = {
      name = "text";
      src = pkgs.fetchFromGitHub {
        owner = "spicetify";
        repo = "spicetify-themes";
        rev = "master";
        hash = "sha256-kpHIWHuubTEwIoi+645Ai/PqXTlZMhRcBueYwgCqG2E=";
      };

      # Additional theme options all set to defaults
      # the docs of the theme should say which of these
      # if any you have to change
      injectCss = true;
      injectThemeJs = true;
      replaceColors = true;
      homeConfig = true;
      overwriteAssets = true;
      additonalCss = "";
    };
    colorScheme = "CatppuccinMocha";
  };
}
