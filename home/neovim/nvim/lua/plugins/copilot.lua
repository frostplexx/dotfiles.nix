return {
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        lazy = true,
        dependencies = {
            { "zbirenbaum/copilot.lua" },                   -- or zbirenbaum/copilot.lua
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken",                            -- Only on MacOS or Linux
        opts = {
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
        },

        keys = {
            { "<leader>cp", ":CopilotChat <cr>", desc = "Open Copilot Chat", silent = true }
        },

    }
}
