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
            keymap = { preset = 'super-tab' },
            completion = {
                menu = { border = 'single' },
                documentation = { window = { border = 'single' } },
            },
            signature = { window = { border = 'single' } },

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
