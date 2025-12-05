---@type vim.lsp.Config

local M = {}

-- Cache for loaded dictionaries to avoid repeated file I/O
local dictionary_cache = {}

-- Get config directory with fallback
local function get_config_dir()
	return vim.fn.stdpath("config") or vim.fn.expand("~/.config/nvim")
end

-- Function to read dictionary file and return words as array (with caching)
local function read_dictionary(file_path)
	if dictionary_cache[file_path] then
		return dictionary_cache[file_path]
	end

	local words = {}
	local file = io.open(file_path, "r")
	if file then
		for line in file:lines() do
			local word = line:match("^%s*(.-)%s*$")
			if word and word ~= "" then
				table.insert(words, word)
			end
		end
		file:close()
		dictionary_cache[file_path] = words
		vim.notify(
			string.format("Loaded %d words from %s", #words, vim.fn.fnamemodify(file_path, ":t")),
			vim.log.levels.INFO
		)
	else
		vim.notify("Dictionary file not found: " .. file_path, vim.log.levels.DEBUG)
	end
	return words
end

-- Lazy load dictionaries only when needed
local function get_dictionaries()
	local config_dir = get_config_dir()
	local ltex_dir = config_dir .. "/ltex"

	-- Try multiple possible locations for dictionaries
	local possible_paths = {
		config_dir .. "/../ltex", -- Current location
		ltex_dir,
		vim.fn.expand("~/.local/share/ltex"),
		vim.fn.expand("~/.config/ltex"),
	}

	local dictionaries = {}

	for _, base_path in ipairs(possible_paths) do
		local en_us_path = base_path .. "/ltex.dictionary.en-US.txt"
		local de_de_path = base_path .. "/ltex.dictionary.de-DE.txt"

		if vim.fn.filereadable(en_us_path) == 1 then
			dictionaries["en-US"] = read_dictionary(en_us_path)
		end

		if vim.fn.filereadable(de_de_path) == 1 then
			dictionaries["de-DE"] = read_dictionary(de_de_path)
		end

		-- If we found at least one dictionary, use this path
		if next(dictionaries) then
			break
		end
	end

	return dictionaries
end

-- Configuration options (can be overridden by users)
M.config = {
	default_language = "en-US",
	mother_tongue = "en-US",
	check_frequency = "edit", -- "edit" or "save"
	enabled_filetypes = {
		"text",
		"plaintex",
		"markdown",
		"latex",
		"tex",
		"gitcommit",
		"org",
		"rst",
		"rnoweb",
		"asciidoc",
		"pandoc",
		"quarto",
		"rmd",
	},
	performance = {
		cache_size = 10000,
		java_opts = "-Xmx1024m", -- Increase memory for better performance
	},
}

-- Helper function to save words to dictionary file
local function save_to_dictionary(lang, words)
	local config_dir = get_config_dir()
	local dict_path = config_dir .. "/ltex/ltex.dictionary." .. lang .. ".txt"

	-- Ensure directory exists
	vim.fn.mkdir(config_dir .. "/ltex", "p")

	-- Read existing words
	local existing = {}
	local file = io.open(dict_path, "r")
	if file then
		for line in file:lines() do
			existing[line] = true
		end
		file:close()
	end

	-- Add new words
	file = io.open(dict_path, "a")
	if file then
		for _, word in ipairs(words) do
			if not existing[word] then
				file:write(word .. "\n")
			end
		end
		file:close()
		-- Clear cache so new words are loaded on next attach
		dictionary_cache = {}
	end
end

-- Helper to save hidden false positives
local function save_hidden_false_positives(lang, fps)
	local config_dir = get_config_dir()
	local fp_path = config_dir .. "/ltex/ltex.hiddenFalsePositives." .. lang .. ".txt"

	vim.fn.mkdir(config_dir .. "/ltex", "p")

	local file = io.open(fp_path, "a")
	if file then
		for _, fp in ipairs(fps) do
			file:write(fp .. "\n")
		end
		file:close()
	end
end

-- Helper to save disabled rules
local function save_disabled_rules(lang, rules)
	local config_dir = get_config_dir()
	local rules_path = config_dir .. "/ltex/ltex.disabledRules." .. lang .. ".txt"

	vim.fn.mkdir(config_dir .. "/ltex", "p")

	local file = io.open(rules_path, "a")
	if file then
		for _, rule in ipairs(rules) do
			file:write(rule .. "\n")
		end
		file:close()
	end
end

return {
	cmd = { "nix-shell", "-p", "ltex-ls", "--run", "ltex-ls" },
	filetypes = M.config.enabled_filetypes,
	root_markers = {
		".ltex",
		".git",
		"src",
		"main.tex",
	},
	handlers = {
		["workspace/executeCommand"] = function(err, result, ctx, config)
			if err then
				vim.notify("LTeX command error: " .. tostring(err), vim.log.levels.ERROR)
				return
			end
			return result
		end,
	},
	on_attach = function(client, bufnr)
		-- Handle LTeX custom commands
		local function handle_ltex_command(command, args)
			if command == "_ltex.addToDictionary" then
				local arg = args[1]
				if arg and arg.words then
					for lang, words in pairs(arg.words) do
						save_to_dictionary(lang, words)
						-- Update client settings
						client.config.settings.ltex.dictionary = client.config.settings.ltex.dictionary or {}
						client.config.settings.ltex.dictionary[lang] = client.config.settings.ltex.dictionary[lang]
							or {}
						for _, word in ipairs(words) do
							table.insert(client.config.settings.ltex.dictionary[lang], word)
						end
					end
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					vim.notify("Added word(s) to dictionary", vim.log.levels.INFO)
				end
				return {}
			elseif command == "_ltex.hideFalsePositives" then
				local arg = args[1]
				if arg and arg.falsePositives then
					for lang, fps in pairs(arg.falsePositives) do
						save_hidden_false_positives(lang, fps)
						client.config.settings.ltex.hiddenFalsePositives = client.config.settings.ltex.hiddenFalsePositives
							or {}
						client.config.settings.ltex.hiddenFalsePositives[lang] = client.config.settings.ltex.hiddenFalsePositives[lang]
							or {}
						for _, fp in ipairs(fps) do
							table.insert(client.config.settings.ltex.hiddenFalsePositives[lang], fp)
						end
					end
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					vim.notify("Hidden false positive(s)", vim.log.levels.INFO)
				end
				return {}
			elseif command == "_ltex.disableRules" then
				local arg = args[1]
				if arg and arg.ruleIds then
					for lang, rules in pairs(arg.ruleIds) do
						save_disabled_rules(lang, rules)
						client.config.settings.ltex.disabledRules = client.config.settings.ltex.disabledRules or {}
						client.config.settings.ltex.disabledRules[lang] = client.config.settings.ltex.disabledRules[lang]
							or {}
						for _, rule in ipairs(rules) do
							table.insert(client.config.settings.ltex.disabledRules[lang], rule)
						end
					end
					client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
					vim.notify("Disabled rule(s)", vim.log.levels.INFO)
				end
				return {}
			end
		end

		-- Register command handler
		local orig_execute_command = vim.lsp.buf.execute_command
		vim.lsp.buf.execute_command = function(command_params)
			if command_params.command and command_params.command:match("^_ltex%.") then
				return handle_ltex_command(command_params.command, command_params.arguments)
			end
			return orig_execute_command(command_params)
		end
		-- Lazy load dictionaries only when LSP attaches
		local dictionaries = get_dictionaries()
		if next(dictionaries) then
			client.config.settings.ltex.dictionary = dictionaries
			client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
		end

		-- Set up keymaps for quick access
		local opts = { buffer = bufnr, silent = true, desc = "LTeX" }
		vim.keymap.set(
			"n",
			"<leader>la",
			vim.lsp.buf.code_action,
			vim.tbl_extend("force", opts, { desc = "LTeX code action" })
		)
		vim.keymap.set(
			"n",
			"<leader>lr",
			"<cmd>LspRestart ltex<CR>",
			vim.tbl_extend("force", opts, { desc = "Restart LTeX" })
		)

		-- Add word to dictionary via code action
		vim.keymap.set("n", "<leader>lw", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.title:match("Add.*to dictionary")
				end,
				apply = true,
			})
		end, vim.tbl_extend("force", opts, { desc = "Add word to dictionary" }))

		-- Ignore rule via code action
		vim.keymap.set("n", "<leader>li", function()
			vim.lsp.buf.code_action({
				filter = function(action)
					return action.title:match("Hide false positive") or action.title:match("Disable rule")
				end,
				apply = true,
			})
		end, vim.tbl_extend("force", opts, { desc = "Ignore LTeX rule" }))
	end,
	settings = {
		ltex = {
			-- Enable for all relevant document types
			enabled = {
				"bibtex",
				"context",
				"context.tex",
				"gitcommit",
				"html",
				"latex",
				"markdown",
				"org",
				"restructuredtext",
				"rsweave",
				"tex",
				"text",
				"xhtml",
			},
			language = M.config.default_language,
			dictionary = {}, -- Will be populated lazily
			checkFrequency = M.config.check_frequency,
			-- Grammar rules configuration
			additionalRules = {
				motherTongue = M.config.mother_tongue,
				-- Enable picky rules for more thorough grammar checking
				enablePickyRules = true,
				-- Use n-gram data for better suggestions (if available)
				languageModel = "",
				neuralModel = "",
				word2VecModel = "",
			},
			-- Disable specific rules that are too noisy
			disabledRules = {
				["en-US"] = {
					"WHITESPACE_RULE", -- Too many false positives in LaTeX
				},
			},
			-- Hide false positives
			hiddenFalsePositives = {},
			-- LaTeX-specific settings
			latex = {
				-- Commands to ignore (won't check spelling in arguments)
				commands = {
					["\\ref"] = "ignore",
					["\\eqref"] = "ignore",
					["\\cite"] = "ignore",
					["\\citep"] = "ignore",
					["\\citet"] = "ignore",
					["\\citeauthor"] = "ignore",
					["\\citeyear"] = "ignore",
					["\\label"] = "ignore",
					["\\input"] = "ignore",
					["\\include"] = "ignore",
					["\\includegraphics"] = "ignore",
					["\\documentclass"] = "ignore",
					["\\usepackage"] = "ignore",
					["\\bibliographystyle"] = "ignore",
					["\\bibliography"] = "ignore",
					["\\url"] = "ignore",
					["\\href"] = "ignore",
					["\\hyperref"] = "ignore",
					["\\lstinputlisting"] = "ignore",
					["\\lstinline"] = "ignore",
					["\\verb"] = "ignore",
					["\\mint"] = "ignore",
					["\\mintinline"] = "ignore",
					["\\inputminted"] = "ignore",
					["\\pgfimage"] = "ignore",
					["\\selectlanguage"] = "ignore",
					["\\foreignlanguage"] = "ignore",
				},
				-- Environments to ignore (won't check content)
				environments = {
					["lstlisting"] = "ignore",
					["verbatim"] = "ignore",
					["minted"] = "ignore",
					["tikzpicture"] = "ignore",
					["equation"] = "ignore",
					["equation*"] = "ignore",
					["align"] = "ignore",
					["align*"] = "ignore",
					["gather"] = "ignore",
					["gather*"] = "ignore",
					["math"] = "ignore",
					["displaymath"] = "ignore",
					["algorithmic"] = "ignore",
					["algorithm"] = "ignore",
					["filecontents"] = "ignore",
				},
			},
			-- Markdown-specific settings
			markdown = {
				nodes = {
					CodeBlock = "ignore",
					FencedCodeBlock = "ignore",
					AutoLink = "ignore",
					Code = "ignore",
				},
			},
			-- Show diagnostics with appropriate severity
			diagnosticSeverity = {
				MORFOLOGIK_RULE_EN_US = "hint", -- Spelling -> hint
				default = "information", -- Grammar -> information
				UPPERCASE_SENTENCE_START = "warning", -- Sentence start -> warning
				EN_UNPAIRED_BRACKETS = "warning", -- Unpaired brackets -> warning
			},
			-- Sentence cache size for performance
			sentenceCacheSize = M.config.performance.cache_size,
			-- Enable completion for suggestions
			completionEnabled = true,
			-- Status bar item (useful for debugging)
			statusBarItem = true,
			-- Trace server communication (for debugging)
			trace = { server = "off" },
		},
	},
}
