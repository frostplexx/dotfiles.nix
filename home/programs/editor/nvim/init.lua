-- [[ Init File ]]
--
if vim.fn.has("nvim-0.10") == 0 then
    vim.notify("This config only supports Neovim 0.10+", vim.log.levels.ERROR)
    return
end

vim.loader.enable() -- speed up startup time
require("core.keymap")   -- load keymaps

_G.dd = function(...)
    Snacks.debug.inspect(...)
end
_G.bt = function()
    Snacks.debug.backtrace()
end
vim.print = _G.dd

-- [[ Lazy.nvim Plugin Manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)
-- initialize lazy.nvim
require("lazy").setup({
    spec = {
        { import = "plugins" },
    },
    dev = {
        path = "~/.local/share/nvim/nix",
        fallback = false,
    },
    defaults = {
        lazy = true,
        version = false, -- always use the latest git commit
    },
    change_detection = {
        notify = false,
    },
    checker = { enabled = false }, -- automatically check for plugin updates
    ui = {
        border = "rounded",
    },
    performance = {
        cache = {
            enabled = true,
        },
        rtp = {
            reset = true, -- reset runtimepath
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})

require("core.lsp")
