---@type vim.lsp.Config
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
            -- Add German as an additional language
            language = "en-US",
            -- Multiple language dictionaries
            dictionary = {
                ["en-US"] = {}, -- American English
                ["en-GB"] = {}, -- British English
                ["de-DE"] = {}, -- German
            },
            -- Disable specific rules per language
            disabledRules = {
                ["en-US"] = {},
                ["en-GB"] = {},
                ["de-DE"] = {},
            },
            -- Additional German-specific settings
            additionalRules = {
                motherTongue = "de-DE", -- Helps with false positives in German
            },
            -- Support for German language variants
            languageVariants = {
                ["de-DE"] = {
                    enabled = true,
                    useAlternativeTypes = true, -- Includes Swiss and Austrian German variations
                }
            }
        }
    }
}
