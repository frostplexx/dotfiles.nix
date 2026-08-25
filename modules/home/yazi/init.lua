require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

require("starship"):setup()
local catppuccin_theme = require("yatline-catppuccin"):setup("mocha") -- or "latte" | "frappe" | "macchiato"
require("yatline"):setup({
	header_line = {},
    theme = catppuccin_theme,
})
