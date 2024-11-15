# pkgs/apple-music/default.nix
{ lib
, stdenv
, fetchurl
, makeWrapper
, electron
, p7zip
}:

stdenv.mkDerivation rec {
  pname = "apple-music-desktop";
  version = "2.1.2";

  src = fetchurl {
    url = "https://github.com/Alex313031/apple-music-desktop/releases/download/${version}/apple-music_${version}_x64.AppImage";
    sha256 = "sha256-ow3At99Y+GYtyTZ03Wr78+FZdLhOfSpBFkj1/wE2has="; # Will be provided by Nix on first build attempt
  };

  nativeBuildInputs = [ makeWrapper p7zip ];

  unpackPhase = ''
    7z x $src
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/512x512/apps $out/share/apple-music-desktop

    # Find and copy required files
    ASAR_PATH=$(find . -name "app.asar")
    LOGO_PATH=$(find . -name "Logo.png")

    # Copy the app files
    mkdir -p $out/share/apple-music-desktop/resources
    cp "$ASAR_PATH" $out/share/apple-music-desktop/resources/

    # Copy the logo if found
    if [ -n "$LOGO_PATH" ]; then
      cp "$LOGO_PATH" $out/share/icons/hicolor/512x512/apps/apple-music-desktop.png
    fi

    # Create wrapper with additional Electron flags and environment variables
    makeWrapper ${electron}/bin/electron $out/bin/apple-music-desktop \
      --set ELECTRON_FORCE_IS_PACKAGED 1 \
      --set ELECTRON_SKIP_BINARY_DOWNLOAD 1 \
      --set ELECTRON_IS_DEV 0 \
      --set NODE_ENV production \
      --add-flags "--no-sandbox" \
      --add-flags "--disable-gpu-sandbox" \
      --add-flags "--disable-software-rasterizer" \
      --add-flags "$out/share/apple-music-desktop/resources/app.asar"

    # Create desktop entry
    cat > $out/share/applications/apple-music-desktop.desktop <<EOF
    [Desktop Entry]
    Name=Apple Music Desktop
    Exec=apple-music-desktop
    Icon=apple-music-desktop
    Type=Application
    Categories=Audio;Music;Player;AudioVideo;
    EOF
  '';

  meta = with lib; {
    description = "Native Apple Music experience for Linux & Windows";
    homepage = "https://github.com/Alex313031/apple-music-desktop";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
