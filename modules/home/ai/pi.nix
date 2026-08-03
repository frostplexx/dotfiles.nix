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
      context = builtins.readFile ./pi_settings/Context.md;
    };
  };
}
