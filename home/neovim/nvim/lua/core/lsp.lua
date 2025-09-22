-- Set up autocommands to attach to lsp
local lsp_dir = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ":p:h") .. '/../../lsp'

-- Prettier-supported filetypes
local prettier_filetypes = {
  "javascript", "javascriptreact", "javascript.jsx",
  "typescript", "typescriptreact", "typescript.tsx",
  "css", "scss", "less", "html", "json", "yaml", "markdown",
  "vue", "graphql"
}

-- Custom formatting function with prettier fallback
local function format_with_prettier_fallback()
  local filetype = vim.bo.filetype
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  -- Check if prettier is available for this filetype
  local prettier_available = false
  for _, client in ipairs(clients) do
    if client.name == "prettier" and vim.tbl_contains(prettier_filetypes, filetype) then
      prettier_available = true
      break
    end
  end

  if prettier_available then
    -- Use prettier
    vim.lsp.buf.format({ name = "prettier" })
  else
    -- Fall back to other LSP formatters
    vim.lsp.buf.format()
  end
end

-- Override the default format function
vim.lsp.buf.format = format_with_prettier_fallback

-- Load LSPs dynamically from the lsp directory
for _, file in ipairs(vim.fn.readdir(lsp_dir)) do
    local lsp_name = file:match("(.+)%.lua$")
    if lsp_name then
        local ok, err = pcall(vim.lsp.enable, lsp_name)
        if not ok then
            vim.notify(
                string.format("Failed to load LSP: %s\nError: %s", lsp_name, err),
                vim.log.levels.WARN,
                {
                    title = "LSP Load Error",
                    icon = "󰅚 ",
                    timeout = 5000
                }
            )
        end
    end
end


vim.lsp.inlay_hint.enable(true)

-- Diagnostic configuration.
vim.diagnostic.config {
    severity_sort = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = tools.ui.diagnostics.ERROR,
            [vim.diagnostic.severity.HINT] = tools.ui.diagnostics.HINT,
            [vim.diagnostic.severity.INFO] = tools.ui.diagnostics.INFO,
            [vim.diagnostic.severity.WARN] = tools.ui.diagnostics.WARN,
        },
    },
    virtual_text = {
        prefix = '',
        spacing = 2,
        source = "if_many",
        -- Sort diagnostics by severity (errors first)
        format = function(diagnostic)
            return diagnostic.message
        end,
    },
    float = {
        source = 'if_many',
        -- Show severity icons as prefixes.
        prefix = function(diag)
            local level = vim.diagnostic.severity[diag.severity]
            local prefix = string.format('%s ', tools.ui.diagnostics[level])
            return prefix, 'Diagnostic' .. level:gsub('^%l', string.upper)
        end,
    },
}
