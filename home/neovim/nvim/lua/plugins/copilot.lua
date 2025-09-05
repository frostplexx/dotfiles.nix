return {
    {
        src = "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
        name = "CopilotChat.nvim",
        lazy = true,
        -- Keymaps (preserved from original keys table)
        build = "make tiktoken",
        config = function()
            require("CopilotChat").setup({
                model = 'claude-sonnet-4',
                mappings = {
                    reset = {
                        normal = '<C-c>',
                        insert = ''
                    },
                    close = {
                        normal = 'q',
                        insert = '',
                    },
                },
            })
        end,
        keys = {
            { "<leader>cp", ":CopilotChat <cr>", desc = "Open Copilot Chat", silent = true }
        },
    },
    {
        src = "https://github.com/zbirenbaum/copilot.lua",
        name = "copilot.lua",
    },
    {
        src = "https://github.com/nvim-lua/plenary.nvim",
        name = "plenary.nvim",
    }
}