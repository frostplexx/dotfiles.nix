#!/usr/bin/env fish

set -g tmp_folder /tmp/tidaluna

set -g tidal_folder = "/Applications/TIDAL.app/Contents/Resources"

function download_tidaluna

    set -l url "https://github.com/Inrixia/TidaLuna/releases/download/latest/luna.zip"
    if test -d "$tmp_folder"
        rm -rf "$tmp_folder"
    end

    git clone --depth 1 "$url" "$tmp_folder"
end



function install_tidaluna

    set -g target_folder "$tidal_folder/app"

    if test -d "$target_folder"
        rm -rf "$target_folder"
    end

    mv "$tmp_folder" "$target_folder"
end
