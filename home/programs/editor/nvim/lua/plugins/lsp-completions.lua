return {
    {
        "saghen/blink.cmp",
        lazy = true,
        event = "InsertEnter",
        dependencies = {
            "rafamadriz/friendly-snippets",
        },
        version = "v0.*",
        opts = {
            -- 'default' for mappings similar to built-in completion
            -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
            -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
            -- see the "default configuration" section below for full documentation on how to define
            -- your own keymap.
            keymap = { preset = 'super-tab' },

            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono'
            },

            -- default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, via `opts_extend`
            sources = {
                completion = {
                    enabled_providers = { 'lsp', 'path', 'snippets', 'buffer' },
                },
            },

            accept = { auto_brackets = { enabled = true } },
            signature = {
                enabled = true,
                window = {
                    border = 'rounded',
                },
            },


            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },
                menu = {
                    border = 'rounded',
                },
                documentation = {
                    -- Controls whether the documentation window will automatically show when selecting a completion item
                    auto_show = true,
                    window = {
                        border = 'rounded',
                    },
                },
                -- Displays a preview of the selected item on the current line
                ghost_text = {
                    enabled = false,
                },
            },

        },
    },
}
-- return {
--     {
--         "hrsh7th/nvim-cmp",
--         event = "InsertEnter",
--         lazy = true,
--         enabled = true,
--         version = false,
--         dependencies = {
--             { "onsails/lspkind.nvim", lazy = true, event = "InsertEnter" },
--             { "hrsh7th/cmp-nvim-lsp", lazy = true, event = "InsertEnter" },
--             { "hrsh7th/cmp-path",     lazy = true, event = "InsertEnter" },
--         },
--         config = function()
--             local cmp = require("cmp")
--             local lspkind = require("lspkind")
--             local luasnip = require("luasnip")
--
--             cmp.setup({
--                 auto_brackets = {},
--                 snippet = {
--                     expand = function(args)
--                         luasnip.lsp_expand(args.body) -- For `luasnip` users.
--                     end,
--                 },
--                 window = {
--                     completion = cmp.config.window.bordered(),
--                     documentation = cmp.config.window.bordered(),
--                 },
--                 formatting = {
--                     format = lspkind.cmp_format({
--                         mode = "symbol_text", -- show only symbol annotations
--                         maxwidth = 50,        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
--                         -- can also be a function to dynamically calculate max width such as
--                         -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
--                         ellipsis_char = "...",    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
--                         show_labelDetails = true, -- show labelDetails in menu. Disabled by default
--
--                         -- The function below will be called before any actual modifications from lspkind
--                         -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
--                         before = function(_, vim_item)
--                             return vim_item
--                         end,
--                     }),
--                 },
--                 view = {
--                     entries = {
--                         -- Makes it so the cmp window follows the cursor while typing
--                         follow_cursor = true,
--                     },
--                 },
--                 mapping = cmp.mapping.preset.insert({
--
--                     ["<CR>"] = cmp.mapping(function(fallback)
--                         if cmp.visible() then
--                             if luasnip.expandable() then
--                                 luasnip.expand()
--                             else
--                                 cmp.confirm({
--                                     select = true,
--                                 })
--                             end
--                         else
--                             fallback()
--                         end
--                     end),
--
--                     -- SuperTab like mappings
--                     ["<Tab>"] = cmp.mapping(function(fallback)
--                         if cmp.visible() then
--                             cmp.select_next_item()
--                         elseif luasnip.locally_jumpable(1) then
--                             luasnip.jump(1)
--                         else
--                             fallback()
--                         end
--                     end, { "i", "s" }),
--
--                     ["<S-Tab>"] = cmp.mapping(function(fallback)
--                         if cmp.visible() then
--                             cmp.select_prev_item()
--                         elseif luasnip.locally_jumpable(-1) then
--                             luasnip.jump(-1)
--                         else
--                             fallback()
--                         end
--                     end, { "i", "s" }),
--                 }),
--                 sources = cmp.config.sources({
--                     { name = "nvim_lsp", priority = 5 },
--                     { name = "luasnip",  priority = 1 },
--                     { name = "path",     priority = 2 },
--                     { name = "lazydev",  group_index = 0 },
--                 }, {
--                     { name = "buffer" },
--                 }),
--             })
--         end,
--     },
--     {
--         "L3MON4D3/LuaSnip",
--         enabled = true,
--         event = "InsertEnter",
--         dependencies = {
--             { "saadparwaiz1/cmp_luasnip",     lazy = true, event = "InsertEnter" },
--             { "rafamadriz/friendly-snippets", lazy = true, event = "InsertEnter" },
--         },
--         config = function()
--             require("luasnip.loaders.from_vscode").lazy_load()
--         end,
--     },
-- }
