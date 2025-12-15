_: {
  languages = {
    enableTreesitter = true;
    enableDAP = true;

    nix = {
      enable = true;
      extraDiagnostics.enable = true;
    };
    ts = {
      enable = true;
      extensions.ts-error-translator.enable = true;
      format.type = "prettierd";
    };
    rust = {
      enable = true;
      crates.enable = true;
      lsp.enable = true;
      dap.enable = true;
      format.enable = true;
    };
    markdown = {
      enable = true;
      extensions.render-markdown-nvim.enable = true;
    };
    clang.enable = true;
    python.enable = true;
  };
}
