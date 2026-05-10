require("git"):setup {
	-- Order of status signs showing in the linemode
	order = 1500,
}

require("mactag"):setup {
	-- Keys used to add or remove tags
	keys = {
		u = "University",
		p = "Project",
	},
	-- Colors used to display tags
	colors = {
		Project  = "#91fc87",
		University = "#cb88f8",
	},
	-- Order of the color circle showing in the line mode
	order = 500,
}
require("starship"):setup()
local catppuccin_theme = require("yatline-catppuccin"):setup("mocha") -- or "latte" | "frappe" | "macchiato"
require("yatline"):setup({
	header_line = {},
    theme = catppuccin_theme,
})
