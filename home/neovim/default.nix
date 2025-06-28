# programs/editor/default.nix
{
    pkgs,
    lib,
    ...
}: let
    # Filter out lazy-lock.json from the source directory
    nvimConfigFiltered = lib.cleanSourceWith {
        src = ./nvim;
        filter = path: _type: let
            baseName = baseNameOf path;
        in
            baseName != "lazy-lock.json";
    };
    treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins: pkgs.tree-sitter.allGrammars);
in {
    programs.neovide = {
        enable = true;
        settings = {
            fork = false;
            frame =
                if pkgs.stdenv.isDarwin
                then "transparent"
                else "none";
            idle = true;
            maximized = false;
            neovim-bin = "${pkgs.neovim}/bin/nvim";
            no-multigrid = false;
            srgb = false;
            tabs = true;
            theme = "auto";
            title-hidden = true;
            vsync = true;
            wsl = false;

            font = {
                family = "Maple Mono NF";
                normal = [];
                size = 12.0;
            };
        };
    };

    programs.neovim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        withNodeJs = true;

        extraPackages = with pkgs; [
            ripgrep
            fd
            git
            nodejs
            tree-sitter
            coreutils
            mermaid-cli # mermaid rendering
            tectonic # latex rendering
            ghostscript # pdf rendering
            luajitPackages.tiktoken_core
            lynx
        ];

        plugins = [
            treeSitterWithAllGrammars
        ];
    };

    # Copy your Neovim configuration
    xdg.configFile = {
        # Copy the filtered nvim configuration directory
        "nvim" = {
            source = nvimConfigFiltered;
            recursive = true;
        };
    };

    home.file = {
        # Copy LTeX configuration files
        # "ltex.hiddenFalsePositives.en-US.txt".text = builtins.readFile ./ltex/ltex.dictionary.en-US.txt;
        # "ltex.dictionary.en-US.txt".text = builtins.readFile ./ltex/ltex.hiddenFalsePositives.en-US.txt;

        # Copy vimrc and ideavimrc
        ".vimrc".text = builtins.readFile ./vimrc;
        ".ideavimrc".text = builtins.readFile ./ideavimrc;

        # Ensure the .local/share/nvim directory exists with correct permissions
        ".local/share/nvim/.keep" = {
            text = "";
            onChange = ''
                mkdir -p $HOME/.local/share/nvim
                chmod 755 $HOME/.local/share/nvim
            '';
        };

        # Treesitter is configured as a locally developed module in lazy.nvim
        # we hardcode a symlink here so that we can refer to it in our lazy config
        ".local/share/nvim/nix/nvim-treesitter/" = {
            recursive = true;
            source = treeSitterWithAllGrammars;
        };
    };
}
