-- Startup time measurement
--local startup_start = vim.loop.hrtime()

-- Global variables.
vim.g.projects_dir = vim.env.HOME .. '/Developer'

-- General Setup (load core modules first)
require 'globals' -- needs to be first
require 'core'
require 'config'

-- Load UI after plugins
require 'ui'

-- Set colorscheme
vim.cmd.colorscheme("catppuccin-mocha")

-- Display startup time
--vim.schedule(function()
--    local startup_time = (vim.loop.hrtime() - startup_start) / 1e6 -- Convert to milliseconds
--    vim.notify(string.format("Neovim started in %.2fms", startup_time), vim.log.levels.INFO)
--end)