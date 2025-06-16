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
    }
}
