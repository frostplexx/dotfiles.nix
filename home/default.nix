{user, ...}: {
  home = {
    username = user;
    stateVersion = "23.11";
    sessionVariables = {
      NH_FLAKE = "$HOME/dotfiles.nix";
      EDITOR = "nvim";
    };
  };

  # sops = {
  #     age.keyFile = keyPath;
  #     age.generateKey = false;
  # };
  #
  # home.activation.fetchAgeKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
  #     ${fetchAgeKey}/bin/fetch-age-key
  # '';

  programs = {
    home-manager.enable = true; # Let Home Manager manage itself
    # zsh.enable = true; # Basic zsh configuration
    opencode = {
      enable = true;
      settings = {
        theme = "catppuccin";
        autoshare = false;
        model = "anthropic/claude-sonnet-4-5";
        small_model = "anthropic/claude-haiku-4-5";
        autoupdate = false;
        disabled_providers = ["xai"];
        permission = {
          webfetch = "allow";
        };

        # LSP Configuration
        lsp = {
          # Custom LSP servers (opencode has built-in support for most, but we ensure they use nix)
          gopls = {
            command = ["nix-shell" "--pure" "-p" "gopls" "--run" "gopls"];
            extensions = [".go"];
          };
          ts_ls = {
            command = ["nix-shell" "-p" "typescript-language-server" "--run" "typescript-language-server --stdio"];
            extensions = [".ts"];
          };
          lua_ls = {
            command = ["nix-shell" "-p" "lua-language-server" "--run" "lua-language-server"];
            extensions = [".lua"];
          };
          fish = {
            command = ["nix-shell" "-p" "fish-lsp" "--run" "fish-lsp start"];
            extensions = [".fish"];
          };
          nixd = {
            command = ["nixd"];
            extensions = [".nix"];
          };
        };

        # Formatter Configuration
        formatter = {
          # JavaScript/TypeScript/JSON/YAML/CSS/HTML/Markdown
          prettier = {
            command = ["nix" "run" "--impure" "nixpkgs#nodePackages.prettier" "--" "--write" "$FILE"];
            extensions = [".js" ".ts" ".jsx" ".tsx" ".json" ".json5" ".jsonc" ".yaml" ".yml" ".css" ".scss" ".less" ".html" ".md" ".mdx" ".graphql" ".vue"];
          };

          # Nix
          alejandra = {
            command = ["nix" "run" "--impure" "nixpkgs#alejandra" "--" "$FILE"];
            extensions = [".nix"];
          };

          # Lua
          stylua = {
            command = ["nix" "run" "--impure" "nixpkgs#stylua" "--" "-" "$FILE"];
            extensions = [".lua"];
          };

          # Go
          gofumpt = {
            command = ["nix" "run" "--impure" "nixpkgs#gofumpt" "--" "-w" "$FILE"];
            extensions = [".go"];
          };

          # Python
          black = {
            command = ["nix" "run" "--impure" "nixpkgs#python3Packages.black" "--" "$FILE"];
            extensions = [".py"];
          };

          # Rust
          rustfmt = {
            command = ["nix" "run" "--impure" "nixpkgs#rustfmt" "--" "$FILE"];
            extensions = [".rs"];
          };

          # Shell
          shfmt = {
            command = ["nix" "run" "--impure" "nixpkgs#shfmt" "--" "-w" "$FILE"];
            extensions = [".sh" ".bash"];
          };

          # Terraform
          terraform_fmt = {
            command = ["nix" "run" "--impure" "nixpkgs#terraform" "--" "fmt" "-"];
            extensions = [".tf" ".tfvars"];
            environment = {
              NIXPKGS_ALLOW_UNFREE = "1";
            };
          };

          # Fish
          fish_indent = {
            command = ["nix" "run" "--impure" "nixpkgs#fish" "--" "fish_indent"];
            extensions = [".fish"];
          };
        };
      };
    };
  };
}
