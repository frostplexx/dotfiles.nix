{
  pkgs,
  lib,
  ...
}: {
  lazy = {
    enable = false;
    plugins = {
      "cord.nvim" = {
        package = pkgs.vimPlugins.cord-nvim;
        event = ["LazyFile"];
        setupModule = "cord";
        setupOpts = {
          editor = {
            tooltip = "How do I exit this?";
          };
          idle = {
            details = lib.generators.mkLuaInline ''
              function(opts)
                  return string.format('Taking a break from %s', opts.workspace)
              end
            '';
          };
          text = {
            editing = lib.generators.mkLuaInline ''
                function(opts)
                  local errors = vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
                  return string.format('Editing %s - %s errors', opts.filename, #errors)
              end
            '';
            workspace = lib.generators.mkLuaInline ''
                function(opts)
                  return string.format("Working on %s", opts.workspace)
              end
            '';
          };
        };

        # after = "print('cord loaded')";
      };
    };
  };
}
