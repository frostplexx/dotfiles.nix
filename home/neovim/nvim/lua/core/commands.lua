
-- Pack command that uses the dedicated pack_manager module
local function PackInfo()
    require('ui.pack_ui').show()
end


vim.api.nvim_create_user_command("Pack", PackInfo, { desc = "Show loaded Neovim plugins in a floating window" })
