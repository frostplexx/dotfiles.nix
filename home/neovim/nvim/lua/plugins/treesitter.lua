return {
    "nvim-treesitter/nvim-treesitter",
    -- The master branch is frozen and provided for backward compatibility only. All future updates happen on the main branch, which will become the default branch in the future.
    branch = "main",
    lazy = true,
    event = { "BufReadPost", "BufWritePost", "BufNewFile", "BufEnter" },
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    dev = false,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
        { "<c-space>", desc = "Increment selection" },
        { "<bs>",      desc = "Decrement selection", mode = "x" },
    },
    opts = {
        highlight = { enable = true },
        indent = { enable = true },
        auto_install = true,
        ensure_installed = {
            "latex",
            "markdown_inline",
            "markdown",
            "css", "html", "javascript", "latex", "norg", "scss", "svelte", "tsx", "typst", "vue", "regex", "lua",
            "diff"
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<C-space>",
                scope_incremental = false,
                node_incremental = "v",
                node_decremental = "V",
            },
        },
        textobjects = {
            move = {
                enable = true,
                goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
                goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer" },
                goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
                goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer" },
            },
        },
    },
    config = function(_, opts)
        if type(opts.ensure_installed) == "table" then
            ---@type table<string, boolean>
            local added = {}
            opts.ensure_installed = vim.tbl_filter(function(lang)
                if added[lang] then
                    return false
                end
                added[lang] = true
                return true
            end, opts.ensure_installed)
        end
        require("nvim-treesitter.configs").setup(opts)
    end,
}
