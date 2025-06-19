return {
    'vyfor/cord.nvim',
    build = ':Cord update',
    lazy = true,
    event = "VeryLazy",
    config = function()
        local errors = {}
        local get_errors = function(bufnr)
            return vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
        end

        -- Debounce error updates
        local timer = vim.uv.new_timer()
        vim.api.nvim_create_autocmd('DiagnosticChanged', {
            callback = function()
                timer:stop()
                timer:start(500, 0, vim.schedule_wrap(function()
                    errors = get_errors(0)
                end))
            end
        })

        require("cord").setup {
            editor = {
                tooltip = "How do I exit this?",
            },
            idle = {
                details = function(opts)
                    return string.format('Taking a break from %s', opts.workspace)
                end
            },
            text = {
                editing = function(opts)
                    return string.format('Editing %s - %s errors', opts.filename, #errors)
                end,
                workspace = function(opts)
                    return string.format("Working on %s", opts.workspace)
                end
            }
        }
    end
}
