return {
  "mikavilpas/yazi.nvim",
  lazy = true,
  keys = {
    {
      -- Open in the current working directory
      "<leader>e",
      "<cmd>Yazi<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      '<c-up>',
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  opts = {
    -- if you want to open yazi instead of netrw, see below for more info
    open_for_directories = true,
    keymaps = {
      show_help = 'g?',
    },
    open_multiple_tabs = true,
    -- window border is set in the yazi config see ~/dotfiles.nix/home/programs/shell/default.nix
    yazi_floating_window_border = 'none',
  },
}
