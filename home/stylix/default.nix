{
    assets,
    pkgs,
    ...
}: {
    stylix = {
        enable = true;
        autoEnable = true;
        base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
        image = "${assets}/wallpapers/wallpaper.png";
        fonts = {
            monospace = {
                package = pkgs.maple-mono.NF;
                name = "Maple Mono NF";
            };
        };
        targets = {
            fish.enable = true;
            neovim = {
                enable = true;
                plugin = "mini.base16";
            };
        };
    };
}
