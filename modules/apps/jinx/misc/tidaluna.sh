#!/usr/bin/env bash


# Exit if not on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is intended for macOS only."
    exit 1
fi


LUNA_RELEASE_URL="https://github.com/Inrixia/TidaLuna/releases/latest/download/luna.zip"
TEMP_DIR=$(mktemp -d)
TIDAL_PATH="/Applications/TIDAL.app/Contents/Resources"

# Check if Tidal exists
if [[ ! -d "$TIDAL_PATH" ]]; then
    echo "TIDAL.app not found in /Applications. Please ensure TIDAL is installed."
    exit 1
fi


# Rename app.asar to original.asar

if [[ -f "$TIDAL_PATH/app.asar" ]]; then
    mv "$TIDAL_PATH/app.asar" "$TIDAL_PATH/original.asar"
elif [[ -f "$TIDAL_PATH/original.asar" ]]; then
    echo "original.asar already exists. Skipping rename."
else
    echo "Neither app.asar nor original.asar found. Exiting."
    exit 1
fi

# Check if app folder already exists and remove it
if [[ -d "$TIDAL_PATH/app" ]]; then
    echo "Removing existing app folder..."
    rm -rf "$TIDAL_PATH/app"
fi

# Download to temp directory
curl -L -o "$TEMP_DIR/luna.zip" "$LUNA_RELEASE_URL"

# Unzip tidaluna.zip into TIDAL_PATH/app
unzip "$TEMP_DIR/luna.zip" -d "$TIDAL_PATH/app" 


# Check if TIDAL is running and kill it
if pgrep -x "TIDAL" > /dev/null; then
    echo "TIDAL is running. Attempting to close it..."
    osascript -e 'quit app "TIDAL"'
    sleep 2  # Wait for a few seconds to ensure it has closed
    if pgrep -x "TIDAL" > /dev/null; then
        echo "TIDAL did not close. Forcing termination..."
        pkill -x "TIDAL"
    fi
fi

# Check if install succeded: You should now have a folder TIDAL\...\resources\app next to original.asar with all the files from luna.zip
if [[ -d "$TIDAL_PATH/app" && -f "$TIDAL_PATH/original.asar" ]]; then
    echo "TidaLuna installed successfully."
    rm -rf "$TEMP_DIR"
else
    echo "Installation failed. Please check the paths and try again."
    exit 1
fi

