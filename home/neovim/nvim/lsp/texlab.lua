---@type vim.lsp.Config
return {
	cmd = { "nix-shell", "-p", "texlab", "--run", "texlab" },
	filetypes = { "tex", "latex", "bib" },
	root_markers = {
		".git",
		"src",
		".ltex",
		".texlabroot",
		"Tectonic.toml",
		"main.tex",
		"*.tex",
	},
	settings = {
		texlab = {
			-- Build settings
			build = {
				executable = "latexmk",
				args = {
					"-pdf",
					"-interaction=nonstopmode",
					"-synctex=1",
					"-shell-escape",
					"%f",
				},
				onSave = false,
				forwardSearchAfter = true,
			},
			-- Forward search configuration for Skim
			forwardSearch = {
				executable = "/Applications/Skim.app/Contents/SharedSupport/displayline",
				args = { "-g", "%l", "%p", "%f" },
			},
			-- Chktex linting
			chktex = {
				onOpenAndSave = true,
				onEdit = false,
			},
			-- Diagnostics settings
			diagnostics = {
				ignoredPatterns = {},
			},
			-- Formatting with latexindent
			latexFormatter = "latexindent",
			latexindent = {
				modifyLineBreaks = false,
			},
			-- Better completion
			completion = {
				matcher = "fuzzy",
			},
		},
	},
}
