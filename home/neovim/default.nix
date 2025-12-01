# programs/editor/default.nix
{pkgs, ...}: let
  # Can be either nvim or nvim-mini
  nvim_config = ./nvim;
  treeSitterWithAllGrammars = pkgs.vimPlugins.nvim-treesitter.withPlugins (_plugins: pkgs.tree-sitter.allGrammars);
in {
  programs = {
    neovim = {
      enable = true;
      package = pkgs.neovim;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;

      extraPackages = with pkgs; [
        ripgrep
        fd
        git
        nodejs
        tree-sitter
        coreutils
        luajitPackages.tiktoken_core
        lynx
        opencode
        # vscode-js-debug
      ];

      plugins = [
        # treeSitterWithAllGrammars
      ];
    };
    gh-dash = {
      enable = true;
      settings = {
        theme = {
          ui = {
            table.compact = true;
          };
          colors = {
            text = {
              primary = "#cdd6f4";
              secondary = "#89b4fa";
              inverted = "#11111b";
              faint = "#bac2de";
              warning = "#f9e2af";
              success = "#a6e3a1";
              error = "#f38ba8";
            };
            background = {
              selected = "#313244";
            };
            border = {
              primary = "#89b4fa";
              secondary = "#45474a";
              faint = "#313244";
            };
          };
        };
        defaults = {
          layout = {
            issues = {
              creator.width = 20;
            };
          };
          view = "issues";
        };
      };
    };
    opencode = {
      enable = true;
      settings = {
        theme = "catppuccin";
        autoshare = false;
        model = "github/claude-sonnet-4-5";
        small_model = "github/claude-haiku-4-5";
        autoupdate = false;
        disabled_providers = ["xAI"];
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

  # Copy your Neovim configuration
  xdg.configFile = {
    # Copy the filtered nvim configuration directory
    "nvim" = {
      source = nvim_config;
      recursive = true;
    };
  };

  home.file = {
    # Copy LTeX configuration files
    # "ltex.hiddenFalsePositives.en-US.txt".text = builtins.readFile ./ltex/ltex.dictionary.en-US.txt;
    # "ltex.dictionary.en-US.txt".text = builtins.readFile ./ltex/ltex.hiddenFalsePositives.en-US.txt;

    # Copy vimrc and ideavimrc
    ".vimrc".text = builtins.readFile ./vimrc;
    ".ideavimrc".text = builtins.readFile ./ideavimrc;

    # Ensure the .local/share/nvim directory exists with correct permissions
    ".local/share/nvim/.keep" = {
      text = "";
      onChange = ''
        mkdir -p $HOME/.local/share/nvim
        chmod 755 $HOME/.local/share/nvim
      '';
    };

    # Treesitter is configured as a locally developed module in lazy.nvim
    # we hardcode a symlink here so that we can refer to it in our lazy config
    ".local/share/nvim/nix/nvim-treesitter/" = {
      recursive = true;
      source = treeSitterWithAllGrammars;
    };
  };
}
