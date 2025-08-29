---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "texlab", "--run", "texlab" },
    filetypes = { 'tex', 'plaintext', 'bib' },
    root_markers = {
        '.git',
        'src',
        '.ltex',
        ".texlabroot",
        "Tectonic.toml",
    },
}
