_: {
  flake.homeManagerModules.rex = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Rex imported themes live under Workspace.customThemes as JSON data, in the
    # shape Rex writes when it imports a Ghostty theme. The palettes are built
    # from the pinned Catppuccin theme files; Rex's generated 16-255 palette is
    # left empty (extended palettes stay off).
    hexDigits = {
      "0" = 0;
      "1" = 1;
      "2" = 2;
      "3" = 3;
      "4" = 4;
      "5" = 5;
      "6" = 6;
      "7" = 7;
      "8" = 8;
      "9" = 9;
      "a" = 10;
      "b" = 11;
      "c" = 12;
      "d" = 13;
      "e" = 14;
      "f" = 15;
    };

    hexDigit = char: hexDigits.${lib.toLower char};

    toRexColor = hex: {
      red = (hexDigit (builtins.substring 0 1 hex) * 16 + hexDigit (builtins.substring 1 1 hex)) / 255.0;
      green = (hexDigit (builtins.substring 2 1 hex) * 16 + hexDigit (builtins.substring 3 1 hex)) / 255.0;
      blue = (hexDigit (builtins.substring 4 1 hex) * 16 + hexDigit (builtins.substring 5 1 hex)) / 255.0;
      alpha = 1.0;
      colorSpace = "srgb";
    };

    mkRexTheme = {
      name,
      id,
      appearance,
      file,
    }: let
      themeFile = pkgs.fetchurl file;
      lines = lib.splitString "\n" (builtins.readFile themeFile);

      namedColor = key: let
        prefix = "${key} = ";
        line = lib.findFirst (line: lib.hasPrefix prefix line) (throw "${file.name}: no ${key}") lines;
      in
        toRexColor (lib.removePrefix "#" (lib.removePrefix prefix line));

      ansiPalette = let
        entries = map (line: {
          name = builtins.head (builtins.match "palette = ([0-9]+)=.*" line);
          value = toRexColor (lib.removePrefix "#" (builtins.elemAt (builtins.match "palette = [0-9]+=(.*)" line) 0));
        }) (lib.filter (line: lib.hasPrefix "palette = " line) lines);
        byIndex = lib.listToAttrs entries;
      in
        lib.genList (index: byIndex.${toString index}) 16;
    in {
      inherit id name appearance;
      palette = {
        ansi = ansiPalette;
        background = namedColor "background";
        foreground = namedColor "foreground";
        cursor = namedColor "cursor-color";
        cursorText = namedColor "cursor-text";
        selectionBackground = namedColor "selection-background";
        selectionForeground = namedColor "selection-foreground";
        paletteBase = {};
        paletteOverrides = {};
        paletteGenerate = false;
        paletteHarmonious = false;
      };
      source.ghosttyFile.fileName = file.name;
      createdAt = 0;
    };

    # Fixed IDs so Workspace.darkThemeID and Workspace.lightThemeID can point at
    # the themes.
    catppuccinMocha = mkRexTheme {
      name = "Catppuccin Mocha";
      id = "custom-5B7A2A3C-1F4D-4E5A-9C8B-7D6E5F4A3B2C";
      appearance = "dark";
      file = {
        name = "catppuccin-mocha.conf";
        url = "https://raw.githubusercontent.com/catppuccin/ghostty/b0b03ccee7ae8f16b13bd4fdfe267616defdb2b7/themes/catppuccin-mocha.conf";
        hash = "sha256-/NwPBF9o16h5f/Xx06dniLwX3VO0Z8Bbe9Zb0UoBMx4=";
      };
    };

    catppuccinLatte = mkRexTheme {
      name = "Catppuccin Latte";
      id = "custom-7C9E1B24-3D5A-4F68-9B0E-2A8F6D4C1E93";
      appearance = "light";
      file = {
        name = "catppuccin-latte.conf";
        url = "https://raw.githubusercontent.com/catppuccin/ghostty/b0b03ccee7ae8f16b13bd4fdfe267616defdb2b7/themes/catppuccin-latte.conf";
        hash = "sha256-S+V2DXWakPAHpwyhgZrgmrHbDIScRi8/O0RZD1EQrvU=";
      };
    };

    rexThemeJSON = builtins.toJSON [catppuccinMocha catppuccinLatte];
  in {
    # Symlink the config directory to ~/.config/rex
    # Symlink instead of using store because i'm lazy and want to modify stuff on the fly.
    xdg.configFile."rex" = {
      source = config.lib.file.mkOutOfStoreSymlink "${./config}";
      recursive = true;
    };

    # The themes cannot go through targets.darwin.defaults: Rex keeps imported
    # themes as JSON data, which a plist attrset cannot express. Writing the key
    # replaces any themes imported in the app.
    home.activation.rexTheme = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin (
      lib.hm.dag.entryAfter ["writeBoundary" "setDarwinDefaults"] ''
        themeHex=$(printf '%s' ${lib.escapeShellArg rexThemeJSON} | ${pkgs.coreutils}/bin/od -An -v -tx1 | ${pkgs.coreutils}/bin/tr -d ' \n')
        run /usr/bin/defaults write com.superlogical.rex 'Workspace.customThemes' -data "$themeHex"
      ''
    );

    targets.darwin.defaults = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "com.superlogical.rex" = {
        RexAppUpdateAutomation = "install";
        # RexAppUpdateChannel = "snapshot";

        "rex.agents.names-sessions" = true;
        "rex.client.remoteControl" = true;
        "rex.developer-mode-enabled" = true;
        "rex.server.automatic-restart-enabled" = true;
        "rex.server.run-mode" = "bundled";
        "rex.server.tailnet-allow-tailnet-members" = true;
        "rex.server.tailnet-enabled" = true;

        "Workspace.activePaneBorderOpacity" = 0.5;
        "Workspace.activePaneBorderTransition" = "instant";
        "Workspace.animationStyle" = "snappy";
        "Workspace.toolbarBehavior" = "onHover";
        "Workspace.appIconVisibility" = "dockOnly";
        "Workspace.appearance" = "dark";
        "Workspace.darkThemeID" = catppuccinMocha.id;
        "Workspace.darkUsesExtendedThemePalette" = false;
        "Workspace.hiddenChromeButtons" = ["commandPalette" "newTab"];
        "Workspace.inactivePaneFadeMode" = "none";
        "Workspace.insertPathShowsRecentPaths" = true;
        "Workspace.interfaceStyle" = "blendTheme";
        "Workspace.lightThemeID" = catppuccinLatte.id;
        "Workspace.lightUsesExtendedThemePalette" = false;
        "Workspace.notificationPosition" = "top-center";
        "Workspace.paneDensity" = "compact";
        "Workspace.shellIconTheme" = "default";
        "Workspace.tabIconColorMode" = "activeTabs";
        "Workspace.showsActivePaneBorder" = true;
        "Workspace.showsIdleProgramsInActivity" = false;
        "Workspace.showsPaneHeaders" = false;
        "Workspace.sidebarCollapsed" = false;
        "Workspace.sidebarPosition" = "left";
        "Workspace.tabIconTintMode" = "off";
        # "Workspace.tabStyle" = "horizontal"; # Don't set tabstyle as I frequently switch between them!
        "Workspace.tabsFillAvailableSpace" = true;
        "Workspace.terminalCopyOnSelect" = false;
        "Workspace.terminalCursorStyle" = "block";
        "Workspace.terminalFontName" = "Maple Mono NF";
        "Workspace.terminalFontPointSize" = 13.0;
        "Workspace.terminalFontSmoothing" = false;
        "Workspace.terminalImproveTextContrast" = false;
        "Workspace.terminalPaddingColor" = "extend";
        "Workspace.terminalSelectionBackground" = "theme";
        "Workspace.terminalSelectionForeground" = "theme";
        "Workspace.terminalSelectionRoundedCorners" = true;
        "Workspace.terminalSmoothScrolling" = true;
        "Workspace.tintsPanesWithProgramBackground" = false;
        "Workspace.usesPaneGlass" = true;
        "Workspace.usesStandardInactiveWindowPaneStyles" = false;
      };
    };
  };
}
