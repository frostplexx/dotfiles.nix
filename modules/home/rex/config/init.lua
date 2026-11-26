require "utils/floating_term"
require "scratchspace"
require "keybindings"
require "sessionizer"
require "smart_splits"
require "worktree"

rex.set("resume.trust.nvim", {
    command = {"nvim", "-S", rex.match.under("~/.local/state/nvim/sessions")}
})
