_: {
  flake.homeManagerModules.pi-coding-agent = {
    config,
    pkgs,
    ...
  }: {
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

        ".pi/agent/extensions" = {
          source = ./extensions;
          recursive = true;
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
        defaultModel = "deepseek-v4.1-flash";
        packages = [
          "git:github.com/elpapi42/pi-fork"
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
