return {
    src = "https://github.com/NickvanDyke/opencode.nvim.git",
    defer = true,
    dependencies = {},
    config = function()
        -- TODO: Wait for mini.nvim to implement terminal
        -- @type opencode.Opts
        -- vim.g.opencode_opts = {
        --     ---@type opencode.Provider
        --     provider = {
        --         toggle = function(self)
        --             -- Called by `require("opencode").toggle()`
        --         end,
        --         start = function(self)
        --             -- Called when sending a prompt or command to `opencode` but no process was found.
        --             -- `opencode.nvim` will poll for a couple seconds waiting for one to appear.
        --         end,
        --         show = function(self)
        --             -- Called when a prompt or command is sent to `opencode`,
        --             -- *and* this provider's `toggle` or `start` has previously been called
        --             -- (so as to not interfere when `opencode` was started externally).
        --         end
        --     }
        -- }

        -- Required for `opts.auto_reload`.
        vim.o.autoread = true

        -- Recommended/example keymaps.
        vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end,
            { desc = "Ask opencode" })

        vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,
            { desc = "Execute opencode action…" })

        vim.keymap.set({ "n", "x" }, "ga", function() require("opencode").prompt("@this") end,
            { desc = "Add to opencode" })

        vim.keymap.set("n", "<C-.>", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

        vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("messages_half_page_up") end,
            { desc = "opencode half page up" })
        vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("messages_half_page_down") end,
            { desc = "opencode half page down" })

        -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
        vim.keymap.set('n', '+', '<C-a>', { desc = 'Increment', noremap = true })
        vim.keymap.set('n', '-', '<C-x>', { desc = 'Decrement', noremap = true })
    end
}
