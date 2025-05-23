---@type vim.lsp.Config
return {
    cmd = { "nix-shell", "-p", "nixd", "--run", "nixd" },
    filetypes = { "nix" },
    root_markers = {
        "flake.nix",
        "shell.nix",
        "default.nix",
        ".git",
        "src",
    },
    settings = {
        nixd = {
            nixpkgs = {
                expr = "import <nixpkgs> { }",
            },
            formatting = {
                command = { "alejandra" }
            },
            options = {
                nixos = {
                    expr = "let flake = builtins.getFlake (toString ./.); in flake.nixosConfigurations.pc-nixos.options"
                },
                darwin = {
                    expr =
                    "let flake = builtins.getFlake (toString ./.); in flake.darwinConfigurations.macbook-pro-m1.options"
                },
                ["home-manager"] = {
                    expr =
                    "let flake = builtins.getFlake (toString ./.); in flake.nixosConfigurations.pc-nixos.config.home-manager.users.daniel.options"
                }
            }
        }
    }
}
