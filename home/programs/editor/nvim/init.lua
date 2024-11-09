-- [[ Init File ]]
vim.loader.enable() -- speed up startup time

require("keymap")   -- load keymaps

-- [[ Lazy.nvim Plugin Manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",     -- latest stable release
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
    version = false,     -- always use the latest git commit
    -- colorscheme = "catppuccin",
  },
  -- install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },   -- automatically check for plugin updates
  ui = {
    border = "rounded",
  },
  performance = {
    cache = {
      enabled = true,
    },
    rtp = {
      reset = true,       -- reset runtimepath
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
