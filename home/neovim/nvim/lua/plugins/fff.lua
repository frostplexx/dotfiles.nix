return {
    'dmtrKovalenko/fff.nvim',
    lazy = true,
    event = "VeryLazy",
    -- build = 'cargo build --release',
    -- or if you are using nixos
    -- build = "nix run .#release",
    opts = { -- (optional)
        prompt = ' ',
        title = 'FFFiles',
        layout = {
            prompt_position = 'top', -- or 'top'
        },
        debug = {
            enabled = false,     -- we expect your collaboration at least during the beta
            show_scores = false, -- to help us optimize the scoring system, feel free to share your scores!
        },

        logging = {
            enabled = false,
        }
    },
    -- No need to lazy-load with lazy.nvim.
    -- This plugin initializes itself lazily.
    keys = {
        {
            "<leader><space>", -- try it if you didn't it is a banger keybinding for a picker
            function() require('fff').find_files() end,
            desc = 'FFFind files',
        }
    }
}
