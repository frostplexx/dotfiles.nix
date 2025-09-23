return {
    src = "https://github.com/mfussenegger/nvim-lint",
    defer = true,
    config = function()
        local lint = require("lint")

        -- === Add your linters here ===
        local linter_specs_by_ft = {
            ["markdown.mdx"] = { name = "markdownlint", pkg = "markdownlint-cli" },
            bash = { name = "shellcheck" },
            css = { name = "stylelint" },
            dockerfile = { name = "hadolint" },
            fish = { name = "fish" },
            go = { name = "golangcilint", pkg = "golangci-lint" },
            graphql = { name = "graphql_schema_linter", pkg = "gqlint" },
            handlebars = { name = "htmlhint" },
            html = { name = "htmlhint" },
            javascript = { name = "eslint" },
            javascriptreact = { name = "eslint" },
            json = { name = "jsonlint", pkg = "nodePackages.jsonlint" },
            json5 = { name = "jsonlint", pkg = "nodePackages.jsonlint" },
            jsonc = { name = "jsonlint", pkg = "nodePackages.jsonlint" },
            less = { name = "stylelint" },
            lua = { name = "luacheck", pkg = "lua54Packages.luacheck" },
            markdown = { name = "markdownlint", pkg = "markdownlint-cli" },
            nix = { name = "statix" },
            python = { name = "pylint" },
            rust = { name = "clippy", pkg = "cargo" },
            scss = { name = "stylelint" },
            sh = { name = "shellcheck" },
            terraform = { name = "tflint" },
            typescript = { name = "eslint" },
            typescriptreact = { name = "eslint" },
            vue = { name = "eslint" },
            yaml = { name = "yamllint" },
            zsh = { name = "shellcheck" },
        }

        local function wrap_with_nix(name, spec)
            spec = spec or {}
            local module = spec.module or name
            local ok, builtin = pcall(require, "lint.linters." .. module)
            if not ok then
                vim.schedule(function()
                    vim.notify(string.format("nvim-lint: builtin '%s' not found", module), vim.log.levels.WARN)
                end)
                return nil
            end

            local function with_nix(def)
                local linter = vim.deepcopy(def)
                linter.cmd = "nix"

                local target = spec.pkg or module
                local args = { "run", "--impure", "nixpkgs#" .. target, "--" }
                if spec.extra_args then
                    vim.list_extend(args, spec.extra_args)
                end
                if type(linter.args) == "table" then
                    vim.list_extend(args, linter.args)
                end
                linter.args = args

                return linter
            end

            if type(builtin) == "function" then
                return function(...)
                    local def = builtin(...)
                    if type(def) ~= "table" then
                        return def
                    end
                    return with_nix(def)
                end
            end

            return with_nix(builtin)
        end

        -- Generate and register linters
        for ft, spec in pairs(linter_specs_by_ft) do
            local linter = wrap_with_nix(spec.name, spec)
            if linter then
                lint.linters[spec.name] = linter
            end
        end

        -- Set up linters_by_ft mapping
        lint.linters_by_ft = {}
        for ft, spec in pairs(linter_specs_by_ft) do
            lint.linters_by_ft[ft] = { spec.name }
        end

        -- Create autocommand which carries out the actual linting
        -- on the specified events.
        local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
        vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
            group = lint_augroup,
            callback = function()
                -- Only run the linter in buffers that you can modify in order to
                -- avoid superfluous noise, notably within the handy LSP pop-ups that
                -- describe the hovered symbol using Markdown.
                if vim.bo.modifiable then
                    lint.try_lint()
                end
            end,
        })

        vim.keymap.set("n", "<leader>cl", function()
            lint.try_lint()
        end, { desc = "Lint current buffer", silent = true })
    end,
}
