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
        vim.notify(string.format("Loaded %d words from %s", #words, vim.fn.fnamemodify(file_path, ":t")), vim.log.levels.INFO)
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
        config_dir .. "/../ltex",  -- Current location
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
    mother_tongue = "de-DE",
    check_frequency = "edit", -- "edit" or "save"
    enabled_filetypes = {
        "text",
        "markdown", 
        "latex",
        "tex",
        "gitcommit",
        "org",
        "rst",
        "rnoweb",
        "asciidoc",
    },
    performance = {
        cache_size = 10000,
        java_opts = "-Xmx512m", -- Reduce memory usage
    }
}

return {
    cmd = { "nix-shell", "-p", "ltex-ls", "--run", "ltex-ls" },
    init_options = {
        quiet = true,
    },
    filetypes = M.config.enabled_filetypes,
    root_markers = {
        ".ltex",
        ".git",
        "src",
        "main.tex",
        "*.tex",
    },
    on_init = function(client, initialize_result)
        -- Performance optimization: reduce memory usage
        client.config.cmd = {
            "nix-shell", "-p", "ltex-ls", "--run",
            string.format("JAVA_OPTS='%s' ltex-ls", M.config.performance.java_opts)
        }
    end,
    on_attach = function(client, bufnr)
        -- Lazy load dictionaries only when LSP attaches
        local dictionaries = get_dictionaries()
        if next(dictionaries) then
            client.config.settings.ltex.dictionary = dictionaries
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
        end
        
        -- Set up keymaps for quick access
        local opts = { buffer = bufnr, silent = true }
        vim.keymap.set('n', '<leader>la', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
        vim.keymap.set('n', '<leader>lr', '<cmd>LspRestart ltex<CR>', opts)
    end,
    settings = {
        ltex = {
            enabled = { 
                "bibtex", "context", "context.tex", "html", 
                "latex", "markdown", "org", "restructuredtext", "rsweave" 
            },
            language = M.config.default_language,
            dictionary = {}, -- Will be populated lazily
            checkFrequency = M.config.check_frequency,
            additionalRules = {
                motherTongue = M.config.mother_tongue,
                enablePickyRules = false, -- Disable picky rules for better performance
            },
            languageVariants = {
                ["de-DE"] = {
                    enabled = true,
                    useAlternativeTypes = true,
                }
            },
            -- Performance optimizations
            completionEnabled = false,
            diagnosticSeverity = "information",
            sentenceCacheSize = M.config.performance.cache_size,
        }
    }
}
