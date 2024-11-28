-- plugins/telescope.lua:
return {
    'nvim-telescope/telescope.nvim',
    lazy = true,
    dependencies = {
        { 'nvim-lua/plenary.nvim',                   lazy = true },
        { "nvim-telescope/telescope-ui-select.nvim", lazy = true }
    },
    config = function()
        -- This is your opts table
        require("telescope").setup {
            extensions = {
                ["ui-select"] = {
                    require("telescope.themes").get_dropdown {}
                }
            }
        }
        -- To get ui-select loaded and working with telescope, you need to call
        -- load_extension, somewhere after setup function:
        require("telescope").load_extension("ui-select")
    end,
    keys = {
        {
            "<leader><space>",
            function()
                require("telescope.builtin").find_files({
                    cwd = vim.loop.cwd(),
                })
            end,
            desc = "Find Files",
            remap = true,
            silent = true
        },
        { "<leader>fg", ":Telescope live_grep<cr>",           desc = "Live Grep",       silent = true },
        { "<leader>fh", ":Telescope help_tags<cr>",           desc = "Help Tags",       silent = true },
        { "<leader>ch", "<cmd>Telescope command_history<cr>", desc = "Command History", silent = true },
        { "<leader>km", ":Telescope keymaps<cr>",             desc = "Keymap",          silent = true },
        { "<leader>bf",
            function()
                local builtin = require("telescope.builtin")

                builtin.buffers({
                    sort_mru = true,
                    ignore_current_buffer = true,
                })
            end
        },
        desc = "List open Buffers",
        remap = true,
        silent = true
    }
}
