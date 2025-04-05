---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "nodePackages.yaml-language-server", "--run", "yaml-language-server --stdio" },
    filetypes = { "yaml", "yml" },
    root_markers = {
        "docker-compose.yml",
        "docker-compose.yaml",
        ".git",
        "src",
    },
}
