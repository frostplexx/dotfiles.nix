-- Helper function to generate nix-shell LSP command configuration
-- @param install_cmd string: Package to install (e.g., 'llvm')
-- @param run_cmd string: Command to run (e.g., 'clangd')
-- @param shell_path string: Optional path to nix-shell, defaults to '/run/current-system/sw/bin/nix-shell'
-- @return table: Array of command segments for LSP configuration
local function make_nix_lsp_cmd(install_cmd, run_cmd, shell_path)
    shell_path = shell_path or '/run/current-system/sw/bin/nix-shell'

    -- Validate inputs
    assert(type(install_cmd) == 'string' and install_cmd ~= '', 'install_cmd must be a non-empty string')
    assert(type(run_cmd) == 'string' and run_cmd ~= '', 'run_cmd must be a non-empty string')
    assert(type(shell_path) == 'string' and shell_path ~= '', 'shell_path must be a non-empty string')

    return {
        shell_path,  -- nix-shell path
        '-p',        -- package flag
        install_cmd, -- package to install
        '--run',     -- run flag
        run_cmd      -- command to run
    }
end

-- Example usage:
-- local config = {
--     cmd = make_nix_lsp_cmd('llvm', 'clangd'),
--     filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
--     -- ... rest of your config
-- }

return make_nix_lsp_cmd
