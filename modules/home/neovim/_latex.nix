# Basic LaTeX treesitter support for the main nvim.
# LSP and full tooling live in _latex-full.nix (used by vtex).
{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption mkOption;
  inherit (lib.types) bool;
  inherit (lib.nvim.types) mkGrammarOption;

  cfg = config.vim.languages.latex;
in {
  options.vim.languages.latex = {
    enable = mkEnableOption "LaTeX language support";

    treesitter = {
      enable = mkOption {
        type = bool;
        default = config.vim.languages.enableTreesitter;
        description = "Enable LaTeX treesitter support";
      };
      package = mkGrammarOption pkgs "latex";
    };
  };

  config = mkIf cfg.enable (mkIf cfg.treesitter.enable {
    vim.treesitter.enable = true;
    vim.treesitter.grammars = [cfg.treesitter.package];
  });
}
