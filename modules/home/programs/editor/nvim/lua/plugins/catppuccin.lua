return {
  "catppuccin/nvim",
  enabled = true,
  event = "WinEnter",
  name = "catppuccin",
  priority = 1000,
  config = function()
    if vim.g.neovide then
      vim.cmd([[
  hi Terminal guibg=NONE ctermbg=NONE cterm=NONE
  hi TermCursor guibg=NONE ctermbg=NONE cterm=NONE ctermfg=1 guifg=mocha_palette.text
  hi TermCursorNC guibg=NONE ctermbg=NONE cterm=NONE ctermfg=1 guifg=mocha_palette.text
  ]])
    end

    -- Set cursor colors to match the theme
    vim.cmd([[
    highlight Cursor guifg=#1b1818 guibg=#cad3f5
    highlight nCursor guifg=#cad3f5 guibg=#cad3f5
    highlight iCursor guifg=#a6da95 guibg=#a6da95
    highlight vCursor guifg=#c6a0f6 guibg=#c6a0f6
    highlight rCursor guifg=#1b1818 guibg=#c6a0f6
    highlight cCursor guifg=#f5a97f guibg=#f5a97f
    " set guicursor=n:block-Cursor
    " set guicursor+=i:block-iCursor
    set guicursor+=n-v-c:noblink
    set guicursor+=n-c:noblink
    set guicursor+=v:noblink-vCursor
    set guicursor+=r:noblink-rCursor
    set guicursor+=c:noblink-cCursor
    set guicursor+=i:blinkwait0
  ]])

    require("catppuccin").setup({
      flavour = "mocha",             -- latte, frappe, macchiato, mocha
      transparent_background = true, -- disables setting the background color.
      term_colors = true,            -- sets terminal colors (e.g. `g:terminal_color_0`)
      integrations = {
        cmp = true,
        gitsigns = true,
        harpoon = true,
        notify = true,
        lsp_trouble = true,
        treesitter = true,
        mason = true,
        telescope = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        mini = {
          enabled = true,
          indentscope_color = "surface2",
        },
      },
    })
  end,
}
