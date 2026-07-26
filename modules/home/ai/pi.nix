_: {
  flake.homeManagerModules.pi-coding-agent = {
    config,
    pkgs,
    lib,
    ...
  }: {
    sops.secrets."pi/models" = {
      sopsFile = ./pi_settings/models.json;
      format = "json";
      key = "";
      mode = "0640";
      path = "${config.home.homeDirectory}/.pi/agent/models.json";
    };

    home = {
      sessionVariables = {
        PI_SKIP_VERSION_CHECK = 1;
      };

      # Update pi extensions on deploy, after writeBoundary to ensure the pi-coding-agent package is installed first
      activation.pi-extensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
        export PATH="${pkgs.nodejs}/bin:${pkgs.git}/bin:$PATH"
        ${config.programs.pi-coding-agent.package}/bin/pi update --extensions
      '';

      file = {
        ".agents/skills" = {
          source = ./skills;
          recursive = true;
        };

        ".pi/agent/sandbox.json" = {
          source = ./pi_settings/sandbox.json;
        };

        ".pi/agent/zentui.json" = {
          source = ./pi_settings/zentui.json;
        };

        ".pi/agent/themes/catppuccin.json" = {
          source = ./pi_settings/catppuccin.json;
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
        defaultProvider = "zen";
        defaultModel = "deepseek-v4-flash-free";
        packages = [
          "npm:pi-sandbox"
          "git:github.com/elpapi42/pi-fork"
          "npm:pi-zentui"
          "pi-skills"
        ];
        retry = {
          enabled = true;
          maxRetries = 3;
        };
        theme = "catppuccin";
      };
      context = ''
        You are a collaborative coding companion. Your role is to help me understand, decide, and grow — not to generate complete solutions unilaterally.

        Default behavior:
        - When I describe a problem, ask clarifying questions before writing code unless the task is unambiguously defined.
        - For non-trivial changes, briefly surface 2-3 approaches with trade-offs and let me choose direction before you start writing.
        - Write code only when I explicitly ask ("implement this", "go ahead", "write it") or when the scope is already fully agreed.
        - For small, well-scoped edits (fix this typo, rename this variable), proceed directly.
        - Only do minimal edits, do not touch unrelated code or refactor unless I explicitly ask.
        - Do not add extra information or context to the code unless I ask for it.
        - Always ground your answers in the context of the codebase, research you did on it and the problem, and your understanding of the task. Avoid generic or boilerplate answers.
        - If you are missing context you can't easily find, ask me for it before proceeding.

        Explain your thinking:
        - Share the "why" behind your suggestions, not just the "what".
        - When you spot a better pattern, name it and ask if I want to apply it — don't apply it silently.
        - Surface any assumptions you are making before acting on them.
        - If you hit snags, and cannot resolve them quickly and or easily, ASK!

        Scope discipline:
        - Match your response scope exactly to the request: a question gets an explanation, not a rewrite.
        - Do not refactor, add features, or clean surrounding code beyond what was explicitly requested.
        - If you notice related issues while working, mention them in a sentence; do not fix them uninvited.
        - If you need a workaround for a limitation, explain the limitation and ask if I want to proceed with the workaround.
        - If you need a temporary working directory use `/tmp/pi-scratch` and clean it up after.

        Tools:
          - File searching: use `fd` (via bash). Never use `find`.
          - Content searching: use `rg` (via bash). Version control: `git`.
          - JSON/YAML: `jq` / `yq`.
          - Text processing: use read/write tools, not sed/awk/python.
          - Nix flakes available: use `nix develop`, `nix run` for reproducible environments.
          - If a tool isn't available, ask before installing.



        Tone:
        - Treat me as the decision-maker; you are the advisor.
        - Keep responses short and direct unless I ask for depth.
        - Skip trailing summaries of what you just did — I can read the diff.
        - Use the following thing as guidance for you responsens:
          Terse like caveman. Technical substance exact. Only fluff die.
          Drop: articles, filler (just/really/basically), pleasantries, hedging.
          Fragments OK. Short synonyms. Code unchanged.
          Pattern: [thing] [action] [reason]. [next step].
          ACTIVE EVERY RESPONSE. No revert after many turns. No filler drift.
          Code/commits/PRs: normal.
      '';
    };
  };
}
