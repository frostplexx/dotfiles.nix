_: {
  flake.homeManagerModules.ai = {pkgs, ...}: let
    model = "gemma4:26b";
    ollama = "${pkgs.ollama}/bin/ollama";
    runnersDir = "${pkgs.ollama}/lib/ollama/runners";
    ai = pkgs.writeShellApplication {
      name = "ai";
      text = ''
        MODEL="${model}"
        export OLLAMA_RUNNERS_DIR="${runnersDir}"

        if ! pgrep -x ollama > /dev/null; then
          ${ollama} serve > /dev/null 2>&1 &
          OLLAMA_PID=$!
          trap 'kill "$OLLAMA_PID"' EXIT

          READY=0
          for _ in $(seq 1 30); do
            if ${ollama} list > /dev/null 2>&1; then
              READY=1
              break
            fi
            sleep 1
          done

          if [ "$READY" -ne 1 ]; then
            echo "Timed out waiting for ollama to become ready." >&2
            exit 1
          fi
        fi

        if ! ${ollama} list | grep -q "^''${MODEL}"; then
          echo "Pulling model ''${MODEL}..."
          ${ollama} pull "''${MODEL}"
        fi

        opencode "$@"
      '';
    };
  in {
    home.packages = [ai];

    home.sessionVariables = {
      AI_MODEL = model;
      OPENCODE_ENABLE_EXA = "1";
      OLLAMA_RUNNERS_DIR = runnersDir;
    };

    programs = {
      opencode = {
        enable = true;
        settings = {
          share = "disabled";
          model = "ollama:${model}";
          small_model = "ollama:${model}";
          autoupdate = false;
          enabled_providers = ["ollama"];
          permission = {
            webfetch = "allow";
          };

          provider = {
            "ollama" = {
              "models" = {
                "${model}" = {
                  "_launch" = true;
                  "name" = model;
                };
              };
              "name" = "Ollama";
              "npm" = "@ai-sdk/openai-compatible";
              "options" = {
                "baseURL" = "http://127.0.0.1:11434/v1";
              };
            };
          };

          # LSP Configuration
          # TODO: Add more
          lsp = {
            gopls = {
              command = ["${pkgs.gopls}/bin/gopls"];
              extensions = [".go"];
            };
            nixd = {
              command = ["${pkgs.nixd}/bin/nixd"];
              extensions = [".nix"];
            };
          };

          # Formatter Configuration
          formatter = {
            # JavaScript/TypeScript/JSON/YAML/CSS/HTML/Markdown
            prettier = {
              command = [
                "${pkgs.prettier}/bin/prettier"
                "--write"
                "$FILE"
              ];
              extensions = [
                ".js"
                ".ts"
                ".jsx"
                ".tsx"
                ".json"
                ".json5"
                ".jsonc"
                ".yaml"
                ".yml"
                ".css"
                ".scss"
                ".less"
                ".html"
                ".md"
                ".mdx"
                ".graphql"
                ".vue"
              ];
            };
            "markdownlint-cli2" = {
              command = [
                "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2"
                "$FILE"
              ];
              extensions = [
                ".md"
                ".mdx"
              ];
            };

            # Nix
            nixfmt.disabled = true;
            alejandra = {
              command = [
                "${pkgs.alejandra}/bin/alejandra"
                "$FILE"
              ];
              extensions = [".nix"];
            };

            # Lua
            stylua = {
              command = [
                "${pkgs.stylua}/bin/stylua"
                "$FILE"
              ];
              extensions = [".lua"];
            };

            # Go
            gofmt = {
              disabled = true;
            };
            gofumpt = {
              command = [
                "${pkgs.gofumpt}/bin/gofumpt"
                "-w"
                "$FILE"
              ];
              extensions = [".go"];
            };
            "goimports-reviser" = {
              command = [
                "${pkgs.goimports-reviser}/bin/goimports-reviser"
                "$FILE"
              ];
              extensions = [".go"];
            };

            # Python
            black = {
              command = [
                "${pkgs.python3Packages.black}/bin/black"
                "$FILE"
              ];
              extensions = [".py"];
            };

            # Rust
            rustfmt = {
              command = [
                "${pkgs.rustfmt}/bin/rustfmt"
                "$FILE"
              ];
              extensions = [".rs"];
            };

            # Shell
            shfmt = {
              command = [
                "${pkgs.shfmt}/bin/shfmt"
                "-i"
                "2"
                "-w"
                "$FILE"
              ];
              extensions = [
                ".sh"
                ".bash"
              ];
            };

            # Terraform
            terraform = {
              command = [
                "${pkgs.opentofu}/bin/tofu"
                "fmt"
                "$FILE"
              ];
              extensions = [
                ".tf"
                ".tfvars"
              ];
            };

            # Fish
            fish_indent = {
              command = [
                "${pkgs.fish}/bin/fish_indent"
                "--write"
                "$FILE"
              ];
              extensions = [".fish"];
            };

            # Swift
            swift-format = {
              command = [
                "${pkgs.swift-format}/bin/swift-format"
                "$FILE"
              ];
              extensions = [".swift"];
            };
          };
        };
        skills = let
          impeccable = builtins.fetchTarball {
            url = "https://github.com/pbakaus/impeccable/archive/15332dd293986e0a310fa54c103025d21142c3dd.tar.gz";
            sha256 = "1a6p5p1h3wk5w6qsvq2lb0dl2nm7y759xyngx7lqrgwdnb7zs1pw";
          };
          caveman = builtins.fetchTarball {
            url = "https://github.com/JuliusBrussee/caveman/archive/refs/heads/main.tar.gz";
            sha256 = "0vhhrjcjza8yfgfxrvs8v5fhrvk30d5bq5b14ymi28jk3m1y0cw0";
          };
          skillsDir = impeccable + "/source/skills";
          cavemanSkillsDir = caveman + "/skills";
        in
          builtins.mapAttrs (name: _: skillsDir + "/${name}") (builtins.readDir skillsDir)
          // builtins.mapAttrs (name: _: cavemanSkillsDir + "/${name}") (builtins.readDir cavemanSkillsDir);
        tui.theme = "catppuccin";
        rules = ''
          Terse like caveman. Technical substance exact. Only fluff die.
          Drop: articles, filler (just/really/basically), pleasantries, hedging.
          Fragments OK. Short synonyms. Code unchanged.
          Pattern: [thing] [action] [reason]. [next step].
          ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
          Code/commits/PRs: normal. Off: "stop caveman" / "normal mode".
        '';
      };
    };
  };
}
