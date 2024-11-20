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
        repo = "spicetify-themes/tree";
        rev = "master/text";
        hash = "sha256-kpHIWHuubTEwIoi+645Ai/PqXTlZMhRcBueYwgCqG2E=";
      };

      patches = {
        "xpui.js_find_8008" = ",(\\w+=)56";
        "xpui.js_repl_8008" = ",\${1}32";
      };
    };
    colorScheme = "CatppuccinMocha";
  };
}
