---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "helm", "--run", "helm_ls --serve" },
    filetypes = { "helm", "helmFile" },
    root_markers = {
        "Chart.yaml",
    },
}
