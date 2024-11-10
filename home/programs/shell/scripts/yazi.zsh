#!/usr/bin/env bash

# Create a temporary file to store the current working directory
tmp="$(mktemp -d -t "yazi-cwd.XXXXXX")/yazi-cwd"

# Run yazi with the provided arguments and specified cwd file
yazi "$@" --cwd-file="$tmp"

# Read the contents of the temporary file
if cwd="$(cat -- "$tmp" 2>/dev/null)" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
fi

# Clean up the temporary file and its directory
rm -f -- "$tmp"
rmdir "$(dirname "$tmp")" 2>/dev/null
