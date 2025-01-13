return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local lint = require("lint")

        lint.linters_by_ft = {
            c = { 'cppcheck' },
            sh = { 'shellcheck' },
            python = { 'pylint', 'ruff' },
            typescript = { 'eslint' },
            -- Apply codespell to all file types
            ['*'] = { 'codespell' },
        }

        -- Configure linters
        -- Configure pylint options
        lint.linters.pylint.args = {
            '--max-line-length=100',
            '--disable=C0111', -- missing-docstring
        }

        -- Configure shellcheck options
        lint.linters.shellcheck.args = {
            '--shell=bash',
            '--severity=warning',
        }

        -- Configure eslint
        lint.linters.eslint.args = {
            '--format=json',
            '--max-warnings=0',
        }

        -- Configure codespell
        lint.linters.codespell.args = {
            '--skip=*.git',
            '--quiet-level=2',
        }

        -- Create autocommand group for linting
        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        -- Setup lint triggers
        vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        -- Optional: Add keymaps for manual linting
        vim.keymap.set("n", "<leader>l", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
