_: {
  # Windowbuddy: directional window focus and space switching/moving for macOS
  # (./windowbuddy/*.c). Exposed as a package so skhd can bind its commands.
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages = lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
      windowbuddy = pkgs.stdenv.mkDerivation {
        pname = "windowbuddy";
        version = "0.1.0";

        src = lib.fileset.toSource {
          root = ./windowbuddy;
          fileset = lib.fileset.fileFilter (file: file.hasExt "c" || file.hasExt "h") ./windowbuddy;
        };

        buildPhase = ''
          runHook preBuild
          $CC -O2 -Wall -Wextra *.c -o windowbuddy \
            -framework ApplicationServices -framework CoreFoundation -framework AppKit -lobjc
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          install -Dm755 windowbuddy $out/bin/windowbuddy
          runHook postInstall
        '';

        meta = {
          description = "Focus windows by direction and switch or move windows between spaces";
          mainProgram = "windowbuddy";
          platforms = lib.platforms.darwin;
        };
      };
    };
  };
}
