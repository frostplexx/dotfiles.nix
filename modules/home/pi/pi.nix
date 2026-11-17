_: {
  flake.homeManagerModules.pi-coding-agent = {
    config,
    pkgs,
    ...
  }: let
    pi-xcode = pkgs.buildNpmPackage {
      pname = "pi-xcode";
      version = "0.2.4";

      src = pkgs.runCommandLocal "pi-xcode-src-0.2.4" {} ''
        cp -r ${pkgs.fetchFromGitHub {
          owner = "ttiimmaahh";
          repo = "pi-xcode";
          tag = "v0.2.4";
          hash = "sha256-WIAvxjwODsoKoTGb7JnUc0wmvOhJwiDqcyWZFX57DFs=";
        }} $out
        chmod -R u+w $out
        # Upstream lockfile omits integrity for three nested pi tarballs, which
        # makes fetchNpmDeps fail. Patch them in.
        ${pkgs.jq}/bin/jq '
          .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-nwnOR3SuLYGRFfyQm8ri4Nj5VGVAvAM9GuqQd3u7BUQj0d6hmD2F8w7OHAAjThE3CuySIdM+v8E22QJG6/RfCg==" |
          .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-ai"].integrity = "sha512-Moe/H8c87yacDGK9dPbWphZNjVsrb3nTrIHycOQJAkFEnY9PYxOOd74+ny44kATfPU9Dm7aTHefar3pZF+UKUA==" |
          .packages["node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-tui"].integrity = "sha512-c2JO29PbhKPEQ6fgHQKAl0WhwuFqzWfzspMmP+8B5tpDuP+0mvarRbKKg8gq4b+pQx/QX+6aVS4ko7deoyjQjg=="
        ' $out/package-lock.json > $out/package-lock.json.tmp
        mv $out/package-lock.json.tmp $out/package-lock.json
      '';

      npmDepsFetcherVersion = 2;
      npmDepsHash = "sha256-G3cz072r61TVgWXO96pY2tAm/o/gISoMij4EapLmZEc=";

      # pi-ai 0.80.10 only uses reasoning_effort for three hardcoded Mistral
      # models and otherwise sends prompt_mode=reasoning, which the API rejects
      # for models that declare a thinkingLevelMap. pi 1.x keys off
      # thinkingLevelMap; backport that check.
      postInstall = ''
        substituteInPlace "$out/lib/node_modules/@ttiimmaahh/pi-xcode/node_modules/@earendil-works/pi-coding-agent/node_modules/@earendil-works/pi-ai/dist/api/mistral-conversations.js" \
          --replace-fail 'return model.id === "mistral-small-2603"' \
          'return Boolean(model.thinkingLevelMap) || model.id === "mistral-small-2603"'
      '';

      meta = {
        description = "Use the pi coding agent as a custom ACP agent in Xcode";
        homepage = "https://github.com/ttiimmaahh/pi-xcode";
        license = pkgs.lib.licenses.mit;
        mainProgram = "pi-xcode";
      };
    };
  in {
    sops.secrets = {
      "pi/models" = {
        sopsFile = ./pi_settings/models.json;
        format = "json";
        key = "";
        mode = "0640";
        path = "${config.home.homeDirectory}/.pi/agent/models.json";
      };
    };

    home = {
      sessionVariables = {
        PI_SKIP_VERSION_CHECK = 1;
      };

      packages = [
        pi-xcode

        # Update pi extensions. Run by `jinx update` rather than on every
        # activation, so deploys don't depend on the network.
        (pkgs.writeShellApplication {
          name = "pi-update-extensions";
          runtimeInputs = [
            pkgs.nodejs
            pkgs.git
          ];
          text = ''
            exec ${config.programs.pi-coding-agent.package}/bin/pi update --extensions
          '';
        })
      ];

      file = {
        ".agents/skills" = {
          source = ./skills;
          recursive = true;
        };

        ".pi/agent/themes/catppuccin.json" = {
          source = ./pi_settings/catppuccin.json;
        };
        ".pi/agent/sandbox.json" = {
          source = ./pi_settings/sandbox.json;
        };

        ".pi/agent/zentui.json" = {
          source = ./pi_settings/zentui.json;
        };

        ".pi/agent/extensions/sandbox-attention.ts" = {
          source = ./pi_settings/extensions/sandbox-attention.ts;
        };
      };
    };

    programs.pi-coding-agent = {
      enable = true;
      settings = {
        compaction = {
          enabled = true;
        };
        hideThinkingBlock = true;
        quietStartup = true;
        enableInstallTelemetry = false;
        enableAnalytics = false;
        warnings.anthropicExtraUsage = false;
        defaultProvider = "mistral";
        defaultModel = "deepseek-v4-1-flash-1017";
        fullscreenCopyOnSelect = false;
        tuiMode = "regular";
        packages = [
          "npm:pi-web-access"
          "pi-skills"
          "npm:pi-sandbox"
          "npm:pi-zentui"
        ];
        retry = {
          enabled = true;
          maxRetries = 3;
        };
        theme = "catppuccin";
      };
      appendSystem = builtins.readFile ./pi_settings/Context.md;
    };
  };
}
