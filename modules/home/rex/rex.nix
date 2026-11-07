_: {
  flake.homeManagerModules.rex = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Symlink the config directory to ~/.config/rex
    # Symlink instead of using store because i'm lazy and want to modify stuff on the fly.
    xdg.configFile."rex" = {
      source = config.lib.file.mkOutOfStoreSymlink "${./config}";
      recursive = true;
    };

    # Rex stores its preferences as flat, dotted keys next to app state
    # (window frames, sync servers, cached routes, recent paths) in one domain.
    # Only preferences are set here; `defaults import` merges, it does not replace.
    targets.darwin.defaults = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "com.superlogical.rex" = {
        RexAppUpdateAutomation = "install";
        # RexAppUpdateChannel = "snapshot";

        "rex.agents.names-sessions" = true;
        "rex.client.remoteControl" = true; #TODO: fix the sessionizer and disable this
        "rex.developer-mode-enabled" = true;
        "rex.server.automatic-restart-enabled" = true;
        "rex.server.run-mode" = "bundled";
        "rex.server.tailnet-allow-tailnet-members" = true;
        "rex.server.tailnet-enabled" = true;

        "Workspace.activePaneBorderOpacity" = 0.5;
        "Workspace.activePaneBorderTransition" = "move";
        "Workspace.animationStyle" = "off";
        "Workspace.appIconVisibility" = "dockOnly";
        "Workspace.appearance" = "dark";
        "Workspace.darkThemeID" = "custom-030FFA16-2348-49CF-B8CE-32DB1B8BE0EE";
        "Workspace.hiddenChromeButtons" = ["commandPalette" "newTab"];
        "Workspace.inactivePaneFadeMode" = "none";
        "Workspace.insertPathShowsRecentPaths" = true;
        "Workspace.interfaceStyle" = "blendTheme";
        "Workspace.lightThemeID" = "merino-light";
        "Workspace.notificationPosition" = "top-center";
        "Workspace.paneDensity" = "compact";
        "Workspace.shellIconTheme" = "themed";
        "Workspace.showsActivePaneBorder" = true;
        "Workspace.showsIdleProgramsInActivity" = false;
        "Workspace.showsPaneHeaders" = false;
        "Workspace.sidebarCollapsed" = false;
        "Workspace.sidebarPosition" = "left";
        "Workspace.tabIconTintMode" = "off";
        "Workspace.tabStyle" = "horizontal";
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
