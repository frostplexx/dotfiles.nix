---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "nodePackages.pyright", "--run", "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".python-version",
        ".env",
        ".git",
        "src",
    },
}
