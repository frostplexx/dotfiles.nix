# programs/editor/default.nix
{
    config,
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
            # lynx
            vscode-js-debug
        ];
    };

    # Copy your Neovim configuration
    xdg.configFile = {
        # Copy the filtered nvim configuration directory
        "nvim" = {
            source = nvimConfigFiltered;
            recursive = true;
        };

        # Generate colors.lua with Stylix colors
        "nvim/lua/ui/colors.lua".text = ''
            require('mini.base16').setup({
              palette = {
                base00 = '#${config.lib.stylix.colors.base00}', base01 = '#${config.lib.stylix.colors.base01}', base02 = '#${config.lib.stylix.colors.base02}', base03 = '#${config.lib.stylix.colors.base03}',
                base04 = '#${config.lib.stylix.colors.base04}', base05 = '#${config.lib.stylix.colors.base05}', base06 = '#${config.lib.stylix.colors.base06}', base07 = '#${config.lib.stylix.colors.base07}',
                base08 = '#${config.lib.stylix.colors.base08}', base09 = '#${config.lib.stylix.colors.base09}', base0A = '#${config.lib.stylix.colors.base0A}', base0B = '#${config.lib.stylix.colors.base0B}',
                base0C = '#${config.lib.stylix.colors.base0C}', base0D = '#${config.lib.stylix.colors.base0D}', base0E = '#${config.lib.stylix.colors.base0E}', base0F = '#${config.lib.stylix.colors.base0F}'
              }
            })
            vim.cmd.highlight({ "Normal", "guibg=NONE", "ctermbg=NONE" })
            vim.cmd.highlight({ "NonText", "guibg=NONE", "ctermbg=NONE" })
            vim.cmd.highlight({ "SignColumn", "guibg=NONE", "ctermbg=NONE" })
            vim.cmd.highlight({ "LineNr", "guibg=NONE", "ctermbg=NONE" })
            vim.cmd.highlight({ "LineNrAbove", "guibg=NONE", "ctermbg=NONE" })
            vim.cmd.highlight({ "LineNrBelow", "guibg=NONE", "ctermbg=NONE" })
            vim.api.nvim_set_hl(0, "WinbarSeparator", { fg = '#${config.lib.stylix.colors.base0B}', bold = true })
            vim.api.nvim_set_hl(0, "WinBarDir", { fg = '#${config.lib.stylix.colors.base05}', italic = true })
            vim.api.nvim_set_hl(0, "Winbar", { fg = '#${config.lib.stylix.colors.base03}' })
        '';
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
