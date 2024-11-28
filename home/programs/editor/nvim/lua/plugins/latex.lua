return {
    {
        "lervag/vimtex",
        lazy = true,
        enabled = true,
        event = "BufRead *.tex",
        ft = { "tex" },
    },
    {
        "barreiroleo/ltex_extra.nvim",
        lazy = true,
        event = "BufRead *.tex",
        enabled = true,
        ft = { "tex" },
        dependencies = { "neovim/nvim-lspconfig" },
        -- yes, you can use the opts field, just I'm showing the setup explicitly
        config = function()
            require("ltex_extra").setup({
                server_opts = {
                    --  function(client, buffer)
                    on_attach = function(_, _)
                        -- your on_attach process
                    end,
                    settings = {
                        ltex = {},
                    },
                },
            })
        end,
    }
}
