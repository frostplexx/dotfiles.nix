_: {
  # Pull-based AI hints (why-hint, diagnostic gloss, statusline file gist)
  # backed by the `pq` one-shot wrapper from ./pi.nix. See ./ai_hints.lua.
  flake.homeManagerModules.neovim-plugin-ai-hints = {inputs, ...}: {
    # Must run after nvf's plugin setup so lualine's config can be extended
    # in place instead of redeclaring its sections.
    programs.nvf.settings.vim.luaConfigRC.ai-hints =
      inputs.nvf.lib.nvim.dag.entryAfter ["pluginConfigs"] (builtins.readFile ./ai_hints.lua);
  };
}
