return {
    "folke/trouble.nvim",
    lazy = true,
    config = function()
        require("trouble").setup({
            icons = {
                -- icons / text used for a diagnostic
                error = "",
                warning = "",
                hint = "",
                information = "",
                other = "",
            },
        })
    end,
    keys = {
        { "<leader>tr", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble" },
    },
}
