return {
    'numToStr/Navigator.nvim',
    event = "VeryLazy",
    config = function()
        require('Navigator').setup()
    end,
    keys = {
        { '<C-h>', '<CMD>NavigatorLeft<CR>',  silent = true, desc = 'Move to left window' },
        { '<C-j>', '<CMD>NavigatorDown<CR>',  silent = true, desc = 'Move to bottom window' },
        { '<C-k>', '<CMD>NavigatorUp<CR>',    silent = true, desc = 'Move to top window' },
        { '<C-l>', '<CMD>NavigatorRight<CR>', silent = true, desc = 'Move to right window' },
    }
}
