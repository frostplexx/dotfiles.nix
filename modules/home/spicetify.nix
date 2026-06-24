_: {
    flake.homeManagerModules.spicetify = {
        pkgs,
        inputs,
        ...
    }: let
        spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
    in {
        programs.spicetify = {
            enable = true;

            # Theme: Catppuccin Macchiato
            theme = spicePkgs.themes.catppuccin;
            colorScheme = "macchiato";

            # Extensions
            enabledExtensions = with spicePkgs.extensions; [
                betterGenres
                hidePodcasts
                history
                keyboardShortcut
                songStats
                wikify
            ];

            # Snippets
            enabledSnippets = with spicePkgs.snippets; [
                fixDjIcon
                fixedEpisodesIcon
            ];
        };
    };
}
