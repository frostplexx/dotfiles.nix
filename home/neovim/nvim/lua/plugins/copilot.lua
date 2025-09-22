return {
    src          = "https://github.com/CopilotC-Nvim/CopilotChat.nvim",
    name         = "CopilotChat.nvim",
    defer        = true,
    dependencies = {
        { src = "https://github.com/nvim-lua/plenary.nvim", },
    },
    data         = { build = "make tiktoken" },
    config       = function()
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
        -- Keymaps
        vim.keymap.set("n", "<leader>cp", ":CopilotChat <cr>", { desc = "Open Copilot Chat", silent = true })
    end,
}
