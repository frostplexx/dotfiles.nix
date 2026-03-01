#!/usr/bin/env fish

set -g tmp_folder /tmp/tidaluna

set -g tidal_folder "/Applications/TIDAL.app/Contents/Resources"

function download_tidaluna

    set -l url "https://github.com/Inrixia/TidaLuna/releases/latest/download/luna.zip"
    if test -d "$tmp_folder"
        rm -rf "$tmp_folder"
    end

    mkdir -p "$tmp_folder"
    curl -L "$url" -o "$tmp_folder/luna.zip"
    unzip "$tmp_folder/luna.zip" -d "$tmp_folder"
    rm "$tmp_folder/luna.zip"
end

function install_tidaluna

    set -g target_folder "$tidal_folder/app"

    if test -d "$target_folder"
        rm -rf "$target_folder"
    end

    mkdir -p "$target_folder"
    echo "Installing TidaLuna to $target_folder"
    cp -R "$tmp_folder/." "$target_folder"

    if test -f "$tidal_folder/original.asar"
        echo "Original asar backup already exists, skipping backup."
        return
    end
    mv "$tidal_folder/app.asar" "$tidal_folder/original.asar"
end

function main
    set -l tidal_was_running false
    if pgrep -x TIDAL > /dev/null
        set tidal_was_running true
        pkill -9 TIDAL
        sleep 1
    end

    download_tidaluna
    install_tidaluna

    codesign --force --deep --sign - /Applications/TIDAL.app

    if test "$tidal_was_running" = true
        open -a TIDAL
    end
end

main
