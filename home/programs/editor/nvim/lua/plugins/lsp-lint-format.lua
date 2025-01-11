return {
    -- {
    --     "frostplexx/mason-bridge.nvim",
    --     lazy = true,
    --     dev = false,
    --     event = { "BufWritePre", "InsertEnter" },
    --     opts = {
    --     },
    --     config = function(_, opts)
    --         require("mason-bridge").setup(opts)
    --     end,
    -- },
    {
        "stevearc/conform.nvim",
        cmd = { "ConformInfo" },
        event = { "BufWritePre", "InsertLeave" },
        config = function()
            local bridge = require("mason-bridge")
            -- This snippet will automatically detect which formatters take too long to run synchronously and will
            -- run them async on save instead.
            local slow_format_filetypes = {}
            require("conform").setup({
                formatters_by_ft = bridge.get_formatters(),
                format_on_save = function(bufnr)
                    require("conform").formatters_by_ft = bridge.get_formatters()

                    if slow_format_filetypes[vim.bo[bufnr].filetype] then
                        return
                    end

                    local function on_format(err)
                        if err and err:match("timeout$") then
                            slow_format_filetypes[vim.bo[bufnr].filetype] = true
                        end
                    end
                    return { timeout_ms = 200, lsp_fallback = true }, on_format
                end,

                format_after_save = function(bufnr)
                    if not slow_format_filetypes[vim.bo[bufnr].filetype] then
                        return
                    end
                    return { lsp_fallback = true }
                end,
            })
        end,
    },
    {

        "mfussenegger/nvim-lint",
        event = { "BufWritePost", "InsertLeave" },
        config = function()
            local bridge = require("mason-bridge")
            -- nvim lint
            local lint = require("lint")
            -- lint.linters_by_ft = bridge.get_linters()

            local lint_autogroup = vim.api.nvim_create_augroup("lint", { clear = true })
            vim.api.nvim_create_autocmd({ "bufwritepost", "insertleave" }, {
                group = lint_autogroup,
                callback = function()
                    -- get the linters for the current filetype
                    local linters = bridge.get_linters()
                    local names = linters[vim.bo.filetype] or {}
                    -- Create a copy of the names table to avoid modifying the original.
                    names = vim.list_extend({}, names)
                    -- insert the linters that have ["*"] as filetype into the names table
                    vim.list_extend(names, linters["*"] or {})
                    -- apply those linters to the current buffer
                    lint.try_lint(names)
                end,
            })
        end,
    },
}
