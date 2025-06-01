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
            language = "en-US",
            dictionary = {
                ["en-US"] = {
                    "/Users/daniel/dotfiles.nix/home/neovim/ltex/ltex.dictionary.en-US.txt",
                },
                ["de-DE"] = {
                    "/Users/daniel/dotfiles.nix/home/neovim/ltex/ltex.dictionary.en-US.txt",
                },
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
