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

    # Debug: List all files to see the structure
    echo "Contents of extracted AppImage:"
    find . -type f
  '';

  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/512x512/apps $out/share/apple-music-desktop

    # Debug: Print current directory contents
    echo "Current directory contents:"
    ls -la

    # Try to locate the app.asar
    ASAR_PATH=$(find . -name "app.asar")
    echo "Found app.asar at: $ASAR_PATH"

    # Try to locate the Logo.png
    LOGO_PATH=$(find . -name "Logo.png")
    echo "Found Logo.png at: $LOGO_PATH"

    # Copy the app files if found
    if [ -n "$ASAR_PATH" ]; then
      mkdir -p $out/share/apple-music-desktop/resources
      cp "$ASAR_PATH" $out/share/apple-music-desktop/resources/
    else
      echo "Error: app.asar not found"
      exit 1
    fi

    # Copy the logo if found
    if [ -n "$LOGO_PATH" ]; then
      cp "$LOGO_PATH" $out/share/icons/hicolor/512x512/apps/apple-music-desktop.png
    else
      echo "Warning: Logo.png not found"
      # Create a placeholder icon if needed
    fi

    # Create wrapper
    makeWrapper ${electron}/bin/electron $out/bin/apple-music-desktop \
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
