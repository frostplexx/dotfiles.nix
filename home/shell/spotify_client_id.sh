#!/usr/bin/env bash

CACHE_FILE="$HOME/.cache/spotify-player/client_id"
CACHE_DIR="$(dirname "$CACHE_FILE")"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Check if cache file exists and is not empty
if [ -s "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
else
    # Get client ID from 1password and save it to cache file
    op read "op://Personal/spotify_player/client_id" | tee "$CACHE_FILE"
fi
