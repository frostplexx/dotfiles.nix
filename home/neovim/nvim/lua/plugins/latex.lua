vim.pack.add({ { src = "https://github.com/lervag/vimtex" } })

-- Skim configuration for macOS
vim.g.vimtex_view_method = "skim"

-- Enable SyncTeX for forward/inverse search with Skim
vim.g.vimtex_view_skim_sync = 1
-- Activate Skim on cursor position change (scroll sync)
vim.g.vimtex_view_skim_activate = 1
-- Reading the output file to get sync info
vim.g.vimtex_view_skim_reading_bar = 1

vim.g.vimtex_quickfix_mode = 0
vim.g.tex_flavor = "latex"

-- Compiler settings for better SyncTeX support
vim.g.vimtex_compiler_latexmk = {
	options = {
		"-pdf",
		"-shell-escape",
		"-verbose",
		"-file-line-error",
		"-synctex=1",
		"-interaction=nonstopmode",
	},
}

-- Keymaps for forward search
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "tex", "latex" },
	callback = function()
		vim.keymap.set(
			"n",
			"<leader>lv",
			"<cmd>VimtexView<CR>",
			{ buffer = true, desc = "VimTeX forward search to Skim" }
		)
		vim.keymap.set("n", "<leader>ll", "<cmd>VimtexCompile<CR>", { buffer = true, desc = "VimTeX compile" })
	end,
})

-- Optional: Auto-sync to Skim when cursor stops moving (CursorHold)
-- Set to false to disable, or adjust updatetime for delay
local auto_sync_enabled = true
if auto_sync_enabled then
	vim.api.nvim_create_autocmd("CursorHold", {
		pattern = { "*.tex" },
		callback = function()
			-- Only sync if VimTeX is active
			if vim.b.vimtex then
				local tex_file = vim.fn.expand("%:p")
				local pdf = tex_file:gsub("%.tex$", ".pdf")
				if vim.fn.filereadable(pdf) == 1 then
					local line = vim.fn.line(".")
					-- Use AppleScript to sync without stealing focus
					local script = string.format(
						[[
						tell application "Skim"
							if (count of documents) > 0 then
								set theDoc to document 1
								set thePage to go theDoc to page %d of theDoc
								tell theDoc to go to TeX line %d from POSIX file "%s"
							end if
						end tell
					]],
						line,
						line,
						tex_file
					)
					vim.fn.jobstart({ "osascript", "-e", script }, { detach = true })
				end
			end
		end,
	})
	-- Adjust delay (in ms) before sync triggers after cursor stops
	vim.api.nvim_create_autocmd("FileType", {
		pattern = { "tex", "latex" },
		callback = function()
			vim.opt_local.updatetime = 1000 -- 1 second delay
		end,
	})
end
