---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "texlab", "--run", "texlab" },
    filetypes = { 'tex', },
    root_markers = {
        '.git',
        'src',
        '.ltex',
        ".texlabroot",
        "Tectonic.toml",
    },
}
