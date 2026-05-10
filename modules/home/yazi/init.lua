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
-- require("starship"):setup()
require("yatline"):setup({
	header_line = {},

	status_line = {
		left = {
			section_a = {
        			{type = "string", custom = false, name = "tab_mode"},
			},
			section_b = {
        			{type = "string", custom = false, name = "hovered_size"},
			},
			section_c = {
        			{type = "string", custom = false, name = "hovered_name"},
			}
		},
		right = {
			section_a = {
        			{type = "string", custom = false, name = "cursor_position"},
			},
			section_b = {
        			{type = "string", custom = false, name = "cursor_percentage"},
			},
			section_c = {
        			{type = "coloreds", custom = false, name = "permissions"},
			}
		}
	},
})
