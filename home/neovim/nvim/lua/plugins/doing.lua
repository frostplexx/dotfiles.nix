return -- minimal installation
{
    "Hashino/doing.nvim",
    cmd = "Do",
    keys = {
        { "<leader>da", function() require("doing").add() end,  { desc = "Doing [A]dd" }, },
        { "<leader>dn", function() require("doing").done() end, { desc = "Doing Do[n]e" }, },
        { "<leader>de", function() require("doing").edit() end, { desc = "Doing [E]dit" }, },
    },
}
