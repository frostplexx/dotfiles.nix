--- gh-dash keybind for opening in a floating terminal

local M = {}

--- Opens gh-dash in a floating terminal window
local function open_gh_dash()
	-- Create a new buffer for the terminal
	local buf = vim.api.nvim_create_buf(false, true)

	-- Get editor dimensions
	local width = vim.api.nvim_get_option("columns")
	local height = vim.api.nvim_get_option("lines")

	-- Calculate floating window size (80% of screen)
	local win_width = math.floor(width * 0.8)
	local win_height = math.floor(height * 0.8)

	-- Calculate starting position (centered)
	local row = math.floor((height - win_height) / 2)
	local col = math.floor((width - win_width) / 2)

	-- Window configuration
	local opts = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		style = "minimal",
		border = "rounded",
	}

	-- Create the floating window
	local win = vim.api.nvim_open_win(buf, true, opts)

	-- Open terminal with gh-dash
	vim.fn.termopen("gh-dash", {
		on_exit = function(_, exit_code, _)
			-- Close the window when gh-dash exits
			vim.schedule(function()
				if vim.api.nvim_win_is_valid(win) then
					vim.api.nvim_win_close(win, true)
				end
			end)
		end,
	})

	-- Enter insert mode in the terminal
	vim.cmd("startinsert")

	-- Set up keybind to close the terminal with ESC in terminal mode
	vim.api.nvim_buf_set_keymap(buf, "t", "<Esc>", "<C-\\><C-n>:q<CR>", {
		noremap = true,
		silent = true,
	})
end

--- Set up keybinds
function M.setup()
	vim.keymap.set("n", "<leader>gh", open_gh_dash, {
		desc = "Open gh-dash in floating terminal",
		noremap = true,
		silent = true,
	})
end

return M
