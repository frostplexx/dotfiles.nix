---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "nodePackages.bash-language-server", "--run", "bash-language-server", "start" },
    filetypes = { "sh", "bash" },
    root_markers = {
        ".bashrc",
        ".bash_profile",
        ".git",
        "src",
    },
}
