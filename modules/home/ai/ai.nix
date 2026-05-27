_: {
  flake.homeManagerModules.ai = {
    pkgs,
    defaults,
    ...
  }: let
    agent-desktop = pkgs.stdenv.mkDerivation rec {
      pname = "agent-desktop";
      version = "0.1.13";

      src = pkgs.fetchurl {
        url = "https://github.com/lahfir/agent-desktop/releases/download/v${version}/agent-desktop-v${version}-aarch64-apple-darwin.tar.gz";
        sha256 = "sha256-cByMKFH3o4sOs+DKVHf3M74p5kMjloyTdRWujHnAfwU=";
      };

      sourceRoot = ".";

      installPhase = ''
        mkdir -p $out/bin
        cp agent-desktop $out/bin/
        chmod +x $out/bin/agent-desktop
      '';

      meta = with pkgs.lib; {
        description = "Native desktop automation CLI for AI agents";
        homepage = "https://github.com/lahfir/agent-desktop";
        license = licenses.asl20;
        platforms = platforms.darwin;
      };
    };
  in {
    home = {
      packages = [
        agent-desktop
      ];

      file = {
        ".claude/themes/rose-pine.json".text = builtins.toJSON {
          "$schema" = "https://raw.githubusercontent.com/matcra587/claude-themes/main/schemas/theme.schema.json";
          name = "Rose Pine Moon";
          base = "dark";
          overrides = {
            text = "rgb(224,222,244)";
            inverseText = "rgb(35,33,54)";
            background = "rgb(35,33,54)";
            subtle = "rgb(110,106,134)";
            inactive = "rgb(68,65,90)";
            inactiveShimmer = "rgb(86,82,110)";
            userMessageBackground = "rgb(42,39,63)";
            userMessageBackgroundHover = "rgb(57,53,82)";
            messageActionsBackground = "rgb(31,29,46)";
            selectionBg = "rgb(57,53,82)";
            bashMessageBackgroundColor = "rgb(42,39,63)";
            memoryBackgroundColor = "rgb(42,39,63)";
            bashBorder = "rgb(235,111,146)";
            promptBorder = "rgb(62,143,176)";
            promptBorderShimmer = "rgb(49,116,143)";
            success = "rgb(156,207,216)";
            error = "rgb(235,111,146)";
            warning = "rgb(246,193,119)";
            warningShimmer = "rgb(218,169,95)";
            merged = "rgb(196,167,231)";
            suggestion = "rgb(156,207,216)";
            diffAdded = "rgb(156,207,216)";
            diffRemoved = "rgb(235,111,146)";
            diffAddedDimmed = "rgb(156,207,216)";
            diffRemovedDimmed = "rgb(235,111,146)";
            diffAddedWord = "rgb(156,207,216)";
            diffRemovedWord = "rgb(235,111,146)";
            autoAccept = "rgb(196,167,231)";
            claude = "rgb(234,154,151)";
            claudeShimmer = "rgb(209,87,125)";
            claudeBlue_FOR_SYSTEM_SPINNER = "rgb(62,143,176)";
            claudeBlueShimmer_FOR_SYSTEM_SPINNER = "rgb(49,116,143)";
            permission = "rgb(62,143,176)";
            permissionShimmer = "rgb(49,116,143)";
            planMode = "rgb(156,207,216)";
            ide = "rgb(62,143,176)";
            red_FOR_SUBAGENTS_ONLY = "rgb(235,111,146)";
            blue_FOR_SUBAGENTS_ONLY = "rgb(62,143,176)";
            green_FOR_SUBAGENTS_ONLY = "rgb(156,207,216)";
            yellow_FOR_SUBAGENTS_ONLY = "rgb(246,193,119)";
            purple_FOR_SUBAGENTS_ONLY = "rgb(196,167,231)";
            orange_FOR_SUBAGENTS_ONLY = "rgb(234,154,151)";
            pink_FOR_SUBAGENTS_ONLY = "rgb(234,154,151)";
            cyan_FOR_SUBAGENTS_ONLY = "rgb(156,207,216)";
            professionalBlue = "rgb(62,143,176)";
            chromeYellow = "rgb(246,193,119)";
            fastMode = "rgb(156,207,216)";
            fastModeShimmer = "rgb(68,65,90)";
            briefLabelYou = "rgb(234,154,151)";
            briefLabelClaude = "rgb(62,143,176)";
            rate_limit_fill = "rgb(235,111,146)";
            rate_limit_empty = "rgb(57,53,82)";
            rainbow_red = "rgb(235,111,146)";
            rainbow_orange = "rgb(234,154,151)";
            rainbow_yellow = "rgb(246,193,119)";
            rainbow_green = "rgb(156,207,216)";
            rainbow_blue = "rgb(62,143,176)";
            rainbow_indigo = "rgb(196,167,231)";
            rainbow_violet = "rgb(196,167,231)";
            rainbow_red_shimmer = "rgb(209,87,125)";
            rainbow_orange_shimmer = "rgb(209,135,132)";
            rainbow_yellow_shimmer = "rgb(218,169,95)";
            rainbow_green_shimmer = "rgb(130,184,195)";
            rainbow_blue_shimmer = "rgb(49,116,143)";
            rainbow_indigo_shimmer = "rgb(176,148,208)";
            rainbow_violet_shimmer = "rgb(176,148,208)";
          };
        };
        ".claude/themes/catppuccin.json".text = builtins.toJSON {
          "$schema" = "https://raw.githubusercontent.com/matcra587/claude-themes/main/schemas/theme.schema.json";
          name = "Catppuccin Mocha";
          base = "dark";
          overrides = {
            text = "rgb(205,214,244)";
            inverseText = "rgb(30,30,46)";
            background = "rgb(30,30,46)";
            subtle = "rgb(127,132,156)";
            inactive = "rgb(88,91,112)";
            inactiveShimmer = "rgb(108,112,134)";
            userMessageBackground = "rgb(49,50,68)";
            userMessageBackgroundHover = "rgb(69,71,90)";
            messageActionsBackground = "rgb(24,24,37)";
            selectionBg = "rgb(69,71,90)";
            bashMessageBackgroundColor = "rgb(49,50,68)";
            memoryBackgroundColor = "rgb(49,50,68)";
            bashBorder = "rgb(243,139,168)";
            promptBorder = "rgb(137,180,250)";
            promptBorderShimmer = "rgb(116,168,252)";
            success = "rgb(166,227,161)";
            error = "rgb(243,139,168)";
            warning = "rgb(249,226,175)";
            warningShimmer = "rgb(235,211,145)";
            merged = "rgb(203,166,247)";
            suggestion = "rgb(148,226,213)";
            diffAdded = "rgb(166,227,161)";
            diffRemoved = "rgb(243,139,168)";
            diffAddedDimmed = "rgb(166,227,161)";
            diffRemovedDimmed = "rgb(243,139,168)";
            diffAddedWord = "rgb(166,227,161)";
            diffRemovedWord = "rgb(243,139,168)";
            autoAccept = "rgb(203,166,247)";
            claude = "rgb(250,179,135)";
            claudeShimmer = "rgb(236,165,121)";
            claudeBlue_FOR_SYSTEM_SPINNER = "rgb(137,180,250)";
            claudeBlueShimmer_FOR_SYSTEM_SPINNER = "rgb(116,168,252)";
            permission = "rgb(137,180,250)";
            permissionShimmer = "rgb(116,168,252)";
            planMode = "rgb(148,226,213)";
            ide = "rgb(137,180,250)";
            red_FOR_SUBAGENTS_ONLY = "rgb(243,139,168)";
            blue_FOR_SUBAGENTS_ONLY = "rgb(137,180,250)";
            green_FOR_SUBAGENTS_ONLY = "rgb(166,227,161)";
            yellow_FOR_SUBAGENTS_ONLY = "rgb(249,226,175)";
            purple_FOR_SUBAGENTS_ONLY = "rgb(203,166,247)";
            orange_FOR_SUBAGENTS_ONLY = "rgb(250,179,135)";
            pink_FOR_SUBAGENTS_ONLY = "rgb(245,194,231)";
            cyan_FOR_SUBAGENTS_ONLY = "rgb(137,220,235)";
            professionalBlue = "rgb(137,180,250)";
            chromeYellow = "rgb(249,226,175)";
            fastMode = "rgb(166,227,161)";
            fastModeShimmer = "rgb(88,91,112)";
            briefLabelYou = "rgb(250,179,135)";
            briefLabelClaude = "rgb(137,180,250)";
            rate_limit_fill = "rgb(243,139,168)";
            rate_limit_empty = "rgb(69,71,90)";
            rainbow_red = "rgb(243,139,168)";
            rainbow_orange = "rgb(250,179,135)";
            rainbow_yellow = "rgb(249,226,175)";
            rainbow_green = "rgb(166,227,161)";
            rainbow_blue = "rgb(137,180,250)";
            rainbow_indigo = "rgb(180,190,254)";
            rainbow_violet = "rgb(203,166,247)";
            rainbow_red_shimmer = "rgb(243,119,153)";
            rainbow_orange_shimmer = "rgb(250,179,135)";
            rainbow_yellow_shimmer = "rgb(235,211,145)";
            rainbow_green_shimmer = "rgb(137,216,139)";
            rainbow_blue_shimmer = "rgb(116,168,252)";
            rainbow_indigo_shimmer = "rgb(180,190,254)";
            rainbow_violet_shimmer = "rgb(203,166,247)";
          };
        };
        ".claude/statusline.sh" = {
          source = ./statusline.sh;
          executable = true;
        };
      };
    };

    programs.claude-code = {
      enable = true;

      # LSP Configuration
      # TODO: Add more
      lspServers = {
        gopls = {
          command = ["${pkgs.gopls}/bin/gopls"];
          extensions = [".go"];
        };
        nixd = {
          command = ["${pkgs.nixd}/bin/nixd"];
          extensions = [".nix"];
        };
      };

      skills = let
        impeccable = pkgs.fetchzip {
          url = "https://github.com/pbakaus/impeccable/archive/15332dd293986e0a310fa54c103025d21142c3dd.tar.gz";
          sha256 = "1a6p5p1h3wk5w6qsvq2lb0dl2nm7y759xyngx7lqrgwdnb7zs1pw";
          stripRoot = true;
        };
        caveman = pkgs.fetchzip {
          url = "https://github.com/JuliusBrussee/caveman/archive/63e797cd753b301374947a5ed975c21775d962b9.tar.gz";
          sha256 = "1ad7k3kkky55dmw9jf4flwwh5asgnrwsirp0a3nfgzpxd90cqwx4";
          stripRoot = true;
        };
        agent-desktop-source = pkgs.fetchzip {
          url = "https://github.com/lahfir/agent-desktop/archive/v0.1.13.tar.gz";
          sha256 = "07lmnb98qab9s2gx7f2437c7xnq0d3lnd4snij6rxn8lb5kfizrn";
          stripRoot = true;
        };
        skillsDir = impeccable + "/source/skills";
        cavemanSkillsDir = caveman + "/skills";
        agentDesktopSkillsDir = agent-desktop-source + "/skills";
      in
        builtins.mapAttrs (name: _: skillsDir + "/${name}") (builtins.readDir skillsDir)
        // builtins.mapAttrs (name: _: cavemanSkillsDir + "/${name}") (builtins.readDir cavemanSkillsDir)
        // builtins.mapAttrs (name: _: agentDesktopSkillsDir + "/${name}") (
          builtins.readDir agentDesktopSkillsDir
        );

      settings = {
        # Anthropic model to use
        model = "claude-sonnet-4-6";

        # Enable ANSI colors in output
        useAnsiColors = true;
        theme =
          {
            "catppuccin" = "custom:catppuccin";
            "rose-pine" = "custom:rose-pine";
          }.${
            defaults.settings.theme
          };

        # Fancy Catppuccin Mocha themed statusline
        statusLine = {
          type = "command";
          command = "$HOME/.claude/statusline.sh";
        };
      };
    };
  };
}
