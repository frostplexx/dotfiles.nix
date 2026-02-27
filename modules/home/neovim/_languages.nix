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
      extensions.crates-nvim.enable = true;
      # lsp.enable = true;
      dap.enable = true;
      format.enable = true;
    };
    # markdown = {
    #   enable = true;
    #   extensions.render-markdown-nvim.enable = true;
    # };
    clang.enable = true;
    # python.enable = true;
    bash.enable = true;
    just.enable = true;
    json.enable = true;
    yaml.enable = true;
    lua.enable = true;

    html.enable = true;

    latex.enable = true;
  };
}
