# programs/editor/default.nix
{pkgs, ...}: let
    # Can be either nvim or nvim-mini
    nvim_config = ./nvim;
    # treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins: pkgs.tree-sitter.allGrammars);
in {
    programs.neovim = {
        enable = true;
        package = pkgs.neovim;
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
            luajitPackages.tiktoken_core
            lynx
            vscode-js-debug
        ];

        plugins = [
            # treeSitterWithAllGrammars
        ];
    };

    # Copy your Neovim configuration
    xdg.configFile = {
        # Copy the filtered nvim configuration directory
        "nvim" = {
            source = nvim_config;
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
        # ".local/share/nvim/nix/nvim-treesitter/" = {
        #     recursive = true;
        #     source = treeSitterWithAllGrammars;
        # };
    };
}
