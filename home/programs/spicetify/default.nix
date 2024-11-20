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
        rev = "c6e82dfeaa46ee9060d0c02fc437989eb77f6c61";
        sha256 = "kpHIWHuubTEwIoi+645Ai/PqXTlZMhRcBueYwgCqG2E=";
        postFetch = ''
          tar xf $downloadedFile --strip=2 "*/text"
        '';
      };
      patches = {
        "xpui.js_find_8008" = ",(\\w+=)56";
        "xpui.js_repl_8008" = ",\${1}32";
      };
       injectCss = true;
  injectThemeJs = true;
  replaceColors = true;
  homeConfig = true;
  overwriteAssets = false;
  additonalCss = "";
    };
    colorScheme = "CatppuccinMocha";
  };
}
