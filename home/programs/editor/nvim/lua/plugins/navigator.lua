return {
    'numToStr/Navigator.nvim',
    config = function()
        require("Navigator").setup();
    end,
    keys = {
        { "<C-h>", "<cmd>NavigatorLeft<CR>",  silent = true, desc = 'Move to left window' },
        { "<C-j>", "<cmd>NavigatorDown<CR>",  silent = true, desc = 'Move to bottom window' },
        { "<C-k>", "<cmd>NavigatorUp<CR>",    silent = true, desc = 'Move to top window' },
        { "<C-l>", "<cmd>NavigatorRight<CR>", silent = true, desc = 'Move to right window' },
    }
}
