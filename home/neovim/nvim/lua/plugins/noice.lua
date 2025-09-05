return {
    {
        src = "https://github.com/folke/noice.nvim",
        name = "noice.nvim",
        keys = {
            { "<leader>n", ":NoiceHistory<cr>", desc = "Show Notification History", remap = true, silent = true }
        },
        config = function()
            require("noice").setup({
                lsp = {
                    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                    override = {
                        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                        ["vim.lsp.util.stylize_markdown"] = true,
                        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                    },
                },
                -- you can enable a preset for easier configuration
                presets = {
                    bottom_search = true,         -- use a classic bottom cmdline for search
                    command_palette = true,       -- position the cmdline and popupmenu together
                    long_message_to_split = true, -- long messages will be sent to a split
                    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    lsp_doc_border = false,       -- add a border to hover docs and signature help
                },
                notify = {
                    enabled = true,
                },
            })
        end
    },
    {
        src = "https://github.com/MunifTanjim/nui.nvim",
        name = "nui.nvim",
    }
}