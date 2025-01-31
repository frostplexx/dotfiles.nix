return {
    {
        "yetone/avante.nvim",
        event = "VeryLazy",
        lazy = false,
        version = false,
        build = "make",
        dependencies = {
            "stevearc/dressing.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
        },
        opts = {
            provider = "openai",
            auto_suggestions_provider = "openai", -- Since auto-suggestions are a high-frequency operation and therefore expensive, it is recommended to specify an inexpensive provider or even a free provider: copilot
            -- openai = {
            --     endpoint = "https://api.deepseek.com/v1",
            --     model = "deepseek-chat",
            --     timeout = 30000, -- Timeout in milliseconds
            --     temperature = 0,
            --     max_tokens = 4096,
            --     -- optional
            --     api_key_name = "OPENAI_API_KEY", -- default OPENAI_API_KEY if not set
            -- },
            hints = { enabled = false },
        },
    }
    -- {
    --     "zbirenbaum/copilot.lua",
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     enabled = true,
    --     config = function()
    --         require("copilot").setup({
    --             suggestion = { enabled = false },
    --             panel = { enabled = false },
    --         })
    --     end,
    -- },
}
