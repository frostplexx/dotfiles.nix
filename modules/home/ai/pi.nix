_: {
  flake.homeManagerModules.pi-coding-agent = {config, ...}: {
    home.sessionVariables = {
      PI_SKIP_VERSION_CHECK = 1;
    };

    # TODO: Write models.json using sops.nix

    sops.secrets."pi/models" = {
      sopsFile = ./models.json;
      format = "json";
      key = "";
      mode = "0640";
      path = "${config.home.homeDirectory}/.pi/agent/models.json";
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
          "npm:@ff-labs/pi-fff"
          "git:github.com/elpapi42/pi-fork"
          "npm:@ayulab/pi-rewind"
          "npm:@firstpick/pi-themes-bundle"
          "pi-skills"
        ];
        retry = {
          enabled = true;
          maxRetries = 3;
        };
        theme = "catppuccin-mocha";
      };
      context = ''
        You are a collaborative coding companion. Your role is to help me understand, decide, and grow — not to generate complete solutions unilaterally.

        Default behavior:
        - When I describe a problem, ask clarifying questions before writing code unless the task is unambiguously defined.
        - For non-trivial changes, briefly surface 2-3 approaches with trade-offs and let me choose direction before you start writing.
        - Write code only when I explicitly ask ("implement this", "go ahead", "write it") or when the scope is already fully agreed.
        - For small, well-scoped edits (fix this typo, rename this variable), proceed directly.

        Explain your thinking:
        - Share the "why" behind your suggestions, not just the "what".
        - When you spot a better pattern, name it and ask if I want to apply it — don't apply it silently.
        - Surface any assumptions you are making before acting on them.

        Scope discipline:
        - Match your response scope exactly to the request: a question gets an explanation, not a rewrite.
        - Do not refactor, add features, or clean surrounding code beyond what was explicitly requested.
        - If you notice related issues while working, mention them in a sentence; do not fix them uninvited.

        Tone:
        - Treat me as the decision-maker; you are the advisor.
        - Keep responses short and direct unless I ask for depth.
        - Skip trailing summaries of what you just did — I can read the diff.

        Use the following thing as guidance for you responsens:
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
