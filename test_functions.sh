#!/bin/bash
set -e

# Extract just the functions from install.sh (before the main if block at line 275)
head -n 274 scripts/install.sh > functions_only.sh
source functions_only.sh

# Test command_exists function
if command_exists git; then
  echo "✓ command_exists works for git"
else
  echo "✗ command_exists failed for git"
  exit 1
fi

# Test check_tools function
if check_tools; then
  echo "✓ check_tools passed"
else
  echo "✗ check_tools failed"
  exit 1
fi

# Test OS detection
if [ "$OS_TYPE" = "Darwin" ]; then
  echo "✓ OS detection works (Darwin detected)"
else
  echo "✗ OS detection failed (expected Darwin, got $OS_TYPE)"
  exit 1
fi

# Test that Xcode CLI tools are present (should be on GitHub runners)
if xcode-select -p >/dev/null 2>&1; then
  echo "✓ Xcode Command Line Tools are installed"
else
  echo "✗ Xcode Command Line Tools not found"
  exit 1
fi

echo "✓ All function tests passed!"
