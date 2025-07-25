-- [[ Init File ]]
if vim.fn.has("nvim-0.11") == 0 then
    vim.notify("This config only supports Neovim 0.11+", vim.log.levels.ERROR)
    return
end

-- Global variables.
vim.g.projects_dir = vim.env.HOME .. '/Developer'

vim.loader.enable() -- speed up startup time

-- Set up snacks debug
_G.dd = function(...)
    Snacks.debug.inspect(...)
end
_G.bt = function()
    Snacks.debug.backtrace()
end
vim.print = _G.dd

-- [[ Lazy.nvim Plugin Manager ]]

-- Install Lazy
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
vim.opt.rtp = vim.opt.rtp ^ lazypath

---@diagnostic disable-next-line: undefined-doc-name
---@type LazySpec
local plugins = 'plugins'


-- General Setup
require 'globals' -- needs to be first
require 'core.options'
require 'core.keymap'
require 'core.commands'
require 'core.autocommands'
require 'core.lsp'

-- initialize lazy.nvim
require("lazy").setup(plugins, {
    ui = { border = "rounded", },
    dev = {
        path = "~/.local/share/nvim/nix",
        fallback = false,
    },
    defaults = {
        lazy = true,
        version = nil,
    },
    change_detection = {
        notify = false,
        enabled = false,
    },
    rocks = { enabled = false },
    checker = {
        enabled = false,
        notify = false,
    },
    performance = {
        cache = {
            enabled = true,
        },
        reset_packpath = true, -- Reset packpath for better performance
        rtp = {
            reset = true,      -- reset the runtime path to $VIMRUNTIME and your config directory
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
                "rplugin", -- Disable remote plugins
                "syntax",  -- Disable vim syntax (use treesitter)
            },
        },
    },
    profiling = {
        loader = false,
        require = false,
    },
})
require 'ui'
