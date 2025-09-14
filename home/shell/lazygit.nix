_: {
    programs.lazygit = {
        enable = true;
        settings = {
            notARepository = "quit";
            git.overrideGpg = true;
            os.editPreset = "nvim";
            gui = {
                border = "rounded";
                nerdFontsVersion = 3;
            };
        };
    };

    programs.lazydocker = {
        enable = true;
    };
}
