return {
    {
        src = "https://github.com/OXY2DEV/markview.nvim",
        name = "markview.nvim",
        lazy = true,
        priority = 49,
        config = function()
            require("markview").setup({
                preview = {
                    icon_provider = "mini", -- "mini" or "devicons" or "internal"
                }
            })
        end
    }
}