{ ...}: {
  autocmds = [
    # {
    #   group = "frostplexx/yank_highlight";
    #   desc = "Highlight on yank";
    #   event = ["TextYankPost"];
    #   callback = lib.generators.mkLuaInline ''
    #     function()
    #           -- Setting a priority higher than the LSP references one.
    #           vim.hl.on_yank { higroup = 'Visual', priority = 250 }
    #       end
    #   '';
    # }
    # {
    #   event = ["FileType"];
    #   pattern = ["help"];
    #   command = "wincmd L";
    # }
  ];
}
