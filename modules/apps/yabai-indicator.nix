_: {
  flake.modules.darwin.yabai-indicator = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.programs.yabaiIndicator;
    yabaiIndicator = pkgs.stdenv.mkDerivation rec {
      pname = "YabaiIndicator";
      version = "0.3.4";
      src = pkgs.fetchurl {
        url = "https://github.com/xiamaz/YabaiIndicator/releases/download/${version}/YabaiIndicator-${version}.zip";
        sha256 = "sha256-Xd4YLa6+P0QhkyMtPN771mNkI1x/oEkLvF5n9C4ZEu8=";
      };
      nativeBuildInputs = [pkgs.unzip];
      sourceRoot = ".";
      unpackPhase = ''
        unzip $src
      '';
      installPhase = ''
        mkdir -p $out/Applications
        cp -r YabaiIndicator-${version}/YabaiIndicator.app $out/Applications/
        mkdir -p $out/bin
        cat > $out/bin/yabai-indicator <<'EOF'
        #!/bin/sh
        open -a "@out@/Applications/YabaiIndicator.app"
        EOF
        substituteInPlace $out/bin/yabai-indicator --replace "@out@" "$out"
        chmod +x $out/bin/yabai-indicator
      '';
      meta = with lib; {
        description = "MacOS Menubar Applet for showing spaces and switching spaces easily";
        homepage = "https://github.com/xiamaz/YabaiIndicator";
        license = licenses.mit;
        platforms = platforms.darwin;
        maintainers = [];
      };
    };
  in {
    options.programs.yabaiIndicator = {
      enable = lib.mkEnableOption "YabaiIndicator - macOS menubar applet for yabai spaces";
      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to automatically start YabaiIndicator at login via launchd.";
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = yabaiIndicator;
        description = "The YabaiIndicator package to use.";
      };
      yabaiSignals = lib.mkOption {
        type = lib.types.lines;
        default = ''
          yabai -m signal --add event=mission_control_exit action='echo "refresh" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=display_added action='echo "refresh" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=display_removed action='echo "refresh" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_created action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_destroyed action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_focused action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_moved action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_resized action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_minimized action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
          yabai -m signal --add event=window_deminimized action='echo "refresh windows" | nc -U /tmp/yabai-indicator.socket'
        '';
        description = "Yabai signals needed for YabaiIndicator to stay in sync. Add these to your .yabairc.";
        readOnly = true;
      };
    };
    config = lib.mkIf cfg.enable {
      environment.systemPackages = [cfg.package];

      launchd.user.agents.yabai-indicator = lib.mkIf cfg.autoStart {
        serviceConfig = {
          Label = "com.yabai-indicator";
          ProgramArguments = [
            "${cfg.package}/bin/yabai-indicator"
          ];
          RunAtLoad = true;
          KeepAlive = false;
          StandardOutPath = "/tmp/yabai-indicator.log";
          StandardErrorPath = "/tmp/yabai-indicator.err";
        };
      };
    };
  };
}
