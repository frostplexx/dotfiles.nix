vim.loader.enable()


require("globals")
require("core.autocmds")
require("core.keymaps")
require("core.options")
require("ui")
require("core.lsp")
require("core.commands")
require("plugins").load()


require("llm").setup({
    model = "github-copilot/gpt-4o", -- or "gpt-4o", "ollama/llama3", etc.
    cmd = "opencode"                 -- Change if your binary is named differently
})


