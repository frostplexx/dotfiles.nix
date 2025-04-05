---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "nil", "--run", "nil" },
    filetypes = { "nix" },
    root_markers = {
        "flake.nix",
        "shell.nix",
        "default.nix",
        ".git",
        "src",
    },
    settings = {
        ['nil'] = {
            formatting = {
                command = { "alejandra" }  -- Using Alejandra instead of nixpkgs-fmt
            },
            nix = {
                maxMemoryMB = 2048,
                flake = {
                    autoEvalInputs = true
                }
            }
        }
    }
}
