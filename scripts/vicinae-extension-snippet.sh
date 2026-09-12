#!/usr/bin/env bash
# Generate a modules/home/vicinae.nix extension snippet.
#
# Usage: scripts/vicinae-extension-snippet.sh [-n|--native] <extension-name> [rev]
#
#   (default)      a Raycast extension from github:raycast/extensions
#   -n, --native   a native Vicinae extension from github:vicinaehq/extensions
#
# <extension-name> is the directory name under extensions/ in that repo.
# [rev] defaults to the current tip of the default branch.

set -euo pipefail

REPO="https://github.com/raycast/extensions.git"
FUNC="mkRaycastExtension"

if [ "${1:-}" = "-n" ] || [ "${1:-}" = "--native" ]; then
  REPO="https://github.com/vicinaehq/extensions.git"
  FUNC="mkNativeExtension"
  shift
fi

name="${1:-}"
rev="${2:-}"

if [ -z "$name" ]; then
  echo "usage: $(basename "$0") [-n|--native] <extension-name> [rev]" >&2
  exit 1
fi

if [ -z "$rev" ]; then
  echo "resolving HEAD of $REPO..." >&2
  rev="$(git ls-remote "$REPO" HEAD | cut -f1)"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "fetching extensions/$name at $rev..." >&2
git init -q "$tmp"
git -C "$tmp" remote add origin "$REPO"
git -C "$tmp" config extensions.partialClone origin
git -C "$tmp" sparse-checkout set "extensions/$name" >/dev/null
git -C "$tmp" fetch -q --depth 1 --filter=blob:none origin "$rev"
git -C "$tmp" checkout -q FETCH_HEAD

if [ ! -d "$tmp/extensions/$name" ]; then
  echo "error: extensions/$name does not exist at $rev" >&2
  exit 1
fi

# Must match the fetchgit invocation in modules/home/vicinae.nix: the store
# contents are just the extension subdirectory, with .git stripped.
rm -rf "$tmp/.git"
hash="$(nix hash path "$tmp/extensions/$name")"

cat <<SNIPPET
        ($FUNC {
          name = "$name";
          rev = "$rev";
          hash = "$hash";
        })
SNIPPET
