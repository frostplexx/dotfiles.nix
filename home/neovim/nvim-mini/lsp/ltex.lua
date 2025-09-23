---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "ltex-ls", "--run", "ltex-ls" },
    filetypes = { 'tex', 'plaintext', 'bib', 'gitcommit', 'markdown', 'org', 'rst', 'rnoweb' },
    root_markers = {
        '.git',
        'src',
        '.ltex',
        ".texlabroot",
        "Tectonic.toml",
    },
}
