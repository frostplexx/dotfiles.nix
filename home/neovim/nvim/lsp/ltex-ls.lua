---@type vim.lsp.Config

-- Function to read dictionary file and return words as array
local function read_dictionary(file_path)
    local words = {}
    local file = io.open(file_path, "r")
    if file then
        for line in file:lines() do
            -- Trim whitespace and add non-empty lines
            local word = line:match("^%s*(.-)%s*$")
            if word and word ~= "" then
                table.insert(words, word)
            end
        end
        file:close()
    else
        vim.notify("Could not read dictionary file: " .. file_path, vim.log.levels.WARN)
    end
    return words
end

-- Read dictionary files
local en_us_dictionary = read_dictionary("/Users/daniel/dotfiles.nix/home/neovim/ltex/ltex.dictionary.en-US.txt")
local de_de_dictionary = read_dictionary("/Users/daniel/dotfiles.nix/home/neovim/ltex/ltex.dictionary.de-DE.txt")

return {
    cmd = { "nix-shell", "-p", "ltex-ls", "--run", "ltex-ls" },
    filetypes = {
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
    root_markers = {
        ".ltex",
        ".git",
        "src",
    },
    settings = {
        ltex = {
            enabled = { "bibtex", "context", "context.tex", "html", "latex", "markdown", "org", "restructuredtext", "rsweave" },
            language = "en-US",
            dictionary = {
                ["en-US"] = en_us_dictionary,
                ["de-DE"] = de_de_dictionary,
            },
            additionalRules = {
                motherTongue = "de-DE",
            },
            languageVariants = {
                ["de-DE"] = {
                    enabled = true,
                    useAlternativeTypes = true,
                }
            }
        }
    }
}
