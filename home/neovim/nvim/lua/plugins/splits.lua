return {
    {
        src = "https://github.com/mrjones2014/smart-splits.nvim",
        name = "smart-splits",
        build = "./kitty/install-kittens.bash",
        -- Keymaps (preserved from original keys table)
        keys = {
            -- resizing splits
            { "<A-h>", function() require('smart-splits').resize_left() end, desc = "Resize Split Left" },
            { "<A-j>", function() require('smart-splits').resize_down() end, desc = "Resize Split Down" },
            { "<A-k>", function() require('smart-splits').resize_up() end, desc = "Resize Split Up" },
            { "<A-l>", function() require('smart-splits').resize_right() end, desc = "Resize Split Right" },
            -- moving between splits
            { "<C-h>", function() require('smart-splits').move_cursor_left() end, desc = "Move to Split Left" },
            { "<C-j>", function() require('smart-splits').move_cursor_down() end, desc = "Move to Split Down" },
            { "<C-k>", function() require('smart-splits').move_cursor_up() end, desc = "Move to Split Up" },
            { "<C-l>", function() require('smart-splits').move_cursor_right() end, desc = "Move to Split Right" },
            { "<C-\\>", function() require('smart-splits').move_cursor_previous() end, desc = "Move to Split Prev" },
            -- swapping buffers between windows
            { "<leader>wh", function() require('smart-splits').swap_buf_left() end, desc = "Split Swap Buffer Left" },
            { "<leader>wj", function() require('smart-splits').swap_buf_down() end, desc = "Split Swap Buffer Down" },
            { "<leader>wk", function() require('smart-splits').swap_buf_up() end, desc = "Split Swap Buffer Up" },
            { "<leader>wl", function() require('smart-splits').swap_buf_right() end, desc = "Split Swap Buffer Right" }
        },
        config = function()
            require('smart-splits').setup()
        end
    }
}