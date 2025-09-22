---@type vim.lsp.Config
return {
  cmd = { "nix-shell", "-p", "nodePackages.prettier", "--run", "prettier --stdin-filepath stdin.js" },
  root_markers = { ".prettierrc", ".prettierrc.json", ".prettierrc.js", "package.json", ".git" },
  filetypes = {
    "javascript", "javascriptreact", "javascript.jsx",
    "typescript", "typescriptreact", "typescript.tsx",
    "css", "scss", "less",
    "html", "json", "yaml", "markdown",
    "vue", "graphql"
  },
  settings = {
    tabWidth = 2,
    useTabs = false,
    semi = true,
    singleQuote = false,
    printWidth = 80,
    trailingComma = "es5"
  }
}