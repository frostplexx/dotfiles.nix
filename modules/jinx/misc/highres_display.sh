#!/bin/bash

# Robust displayplacer command with comprehensive error handling
set -e

# Define the display ID and target resolution
DISPLAY_ID="1634D053-DD54-4B01-BFD7-C1E1FF4C626A"
TARGET_RES="res:2560x1080 hz:144 color_depth:8 scaling:on"

echo "Checking display configuration..."

# Check if displayplacer is available
if ! command -v displayplacer &> /dev/null; then
    echo "Error: displayplacer is not installed"
    echo "Install with: brew install jakehilborn/jakehilborn/displayplacer"
    exit 1
fi

# Get list of displays and check if target display is connected
DISPLAY_LIST=$(displayplacer list 2>/dev/null || {
    echo "Error: Failed to get display list"
    exit 1
})

# Check if the target display ID exists in the output
if ! echo "$DISPLAY_LIST" | grep -q "id:$DISPLAY_ID"; then
    echo "Error: Display with ID $DISPLAY_ID is not connected"
    echo ""
    echo "Connected displays:"
    echo "$DISPLAY_LIST" | grep -E "^Persistent screen id:" | while read -r line; do
        echo "  $line"
    done
    echo ""
    echo "Available display IDs:"
    echo "$DISPLAY_LIST" | grep -oE "id:[A-F0-9-]+" | sort -u
    exit 0
fi

echo "✓ Target display is connected"

# Get the mode ID for the specific display with better error handling
MODE_ID=$(echo "$DISPLAY_LIST" |grep "$TARGET_RES" | awk '{print $2}' | cut -d':' -f1)

# Check if we found a mode ID for this specific display
if [ -z "$MODE_ID" ]; then
    echo "Error: Could not find mode '$TARGET_RES' for display $DISPLAY_ID"
    echo ""
    echo "Available modes for this display:"
    echo "$DISPLAY_LIST" | awk -v display_id="$DISPLAY_ID" '
    BEGIN { found_display = 0 }
    /^Persistent screen id:/ && $0 ~ display_id { found_display = 1; print "Display: " $0; next }
    found_display && /res:/ { print "  " $0 }
    /^Persistent screen id:/ && $0 !~ display_id { found_display = 0 }
    '
    exit 1
fi

echo "✓ Found mode ID: $MODE_ID"
echo "✓ Applying display configuration..."

# Execute the displayplacer command with error handling
if displayplacer "id:$DISPLAY_ID mode:$MODE_ID" 2>/dev/null; then
    echo "✓ Display configuration applied successfully!"
else
    echo "Error: Failed to apply display configuration"
    echo "This might happen if:"
    echo "  - The display was disconnected during execution"
    echo "  - The mode is not currently available"
    echo "  - System permissions are insufficient"
    exit 1
fi
