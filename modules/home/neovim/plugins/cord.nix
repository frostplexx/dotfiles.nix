_: {
    flake.homeManagerModules.neovim-plugin-cord = {
        pkgs,
        lib,
        ...
    }: {
        programs.nvf.settings.vim.lazy.plugins."cord.nvim" = {
            package = pkgs.vimPlugins.cord-nvim;
            lazy = true;
            event = [
                {
                    event = "User";
                    pattern = "LazyFile";
                }
            ];
            setupModule = "cord";
            setupOpts = {
                editor = {
                    tooltip = "How do I exit this?";
                };
                idle = {
                    details = lib.generators.mkLuaInline ''
                        function(opts)
                            return string.format('Taking a break from %s', opts.workspace)
                        end
                    '';
                };
                text = {
                    editing = lib.generators.mkLuaInline ''
                          function(opts)
                            local errors = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
                            return string.format('Editing %s - %s errors', opts.filename, #errors)
                        end
                    '';
                    workspace = lib.generators.mkLuaInline ''
                          function(opts)
                            return string.format("Working on %s", opts.workspace)
                        end
                    '';
                };
            };
        };
    };
}
