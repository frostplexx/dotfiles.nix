return {
    'vyfor/cord.nvim',
    build = ':Cord update',
    lazy = true,
    event = "VeryLazy",
    opts = {
        editor = {
            tooltip = "How do I exit this?",
        }
    }
}
