---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "metals", "--run", "metals" },
    root_markers = { ".git" },
    filetypes = { "scala" },
}
