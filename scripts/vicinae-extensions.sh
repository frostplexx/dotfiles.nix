#!/usr/bin/env bash
# Manage the pinned extension sources in modules/home/vicinae-extensions.json.
#
#   vicinae-extensions.sh update [<repo>[/<name>]]...
#   vicinae-extensions.sh add <repo> <name> [rev]
#   vicinae-extensions.sh remove <repo> <name>
#
#   <repo> is a top-level key in the JSON ("raycast" or "vicinae").
#
# `update` with no arguments bumps every extension to the current tip of its
# repo's default branch and recomputes its hash. Entries marked "pinned": true
# are left alone -- use that to hold an extension back when upstream breaks it.
#
# Requires: git, jq, nix.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
db="$repo_root/modules/home/vicinae-extensions.json"

die() {
  echo "error: $*" >&2
  exit 1
}

[ -f "$db" ] || die "$db not found"
for bin in git jq nix; do
  command -v "$bin" >/dev/null || die "$bin is not on PATH"
done

# jq_set <filter> -- rewrite the db in place, atomically.
jq_set() {
  local tmp
  tmp="$(mktemp)"
  jq "$@" "$db" >"$tmp"
  mv "$tmp" "$db"
}

repo_url() {
  jq -r --arg r "$1" '.[$r].url // empty' "$db"
}

# resolve_head <url> -- tip of the default branch, memoised per run.
declare -A head_cache=()
resolve_head() {
  local url="$1"
  if [ -z "${head_cache[$url]:-}" ]; then
    local rev
    rev="$(git ls-remote "$url" HEAD | cut -f1)"
    [ -n "$rev" ] || die "could not resolve HEAD of $url"
    head_cache[$url]="$rev"
  fi
  printf '%s' "${head_cache[$url]}"
}

# prefetch <url> <name> <rev> -- print the NAR hash of extensions/<name> at <rev>.
#
# Must mirror the pkgs.fetchgit invocation in modules/home/vicinae.nix:
# a sparse checkout of extensions/<name>, with rootDir moving that directory
# into place and .git stripped.
prefetch() {
  local url="$1" name="$2" rev="$3" tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN

  git init -q "$tmp"
  git -C "$tmp" remote add origin "$url"
  git -C "$tmp" config extensions.partialClone origin
  git -C "$tmp" sparse-checkout set "extensions/$name" >/dev/null
  git -C "$tmp" fetch -q --depth 1 --filter=blob:none origin "$rev"
  git -C "$tmp" checkout -q FETCH_HEAD

  [ -d "$tmp/extensions/$name" ] || die "extensions/$name does not exist at ${rev:0:8}"

  rm -rf "$tmp/.git"
  nix --extra-experimental-features nix-command hash path "$tmp/extensions/$name"
}

cmd_update() {
  local -a raw=() targets=()
  if [ $# -gt 0 ]; then
    raw=("$@")
  else
    mapfile -t raw < <(jq -r 'keys[]' "$db")
  fi

  # Expand bare repo names ("vicinae") into "<repo>/<name>" pairs.
  local arg
  for arg in "${raw[@]}"; do
    if [[ "$arg" == */* ]]; then
      targets+=("$arg")
    else
      local -a expanded=()
      mapfile -t expanded < <(jq -r --arg r "$arg" '.[$r].extensions | keys[]' "$db")
      [ ${#expanded[@]} -gt 0 ] || die "no extensions under '$arg'"
      targets+=("${expanded[@]/#/$arg/}")
    fi
  done

  local changed=0 failed=0 target

  for target in "${targets[@]}"; do
    local repo name url old_rev old_hash pinned
    repo="${target%%/*}"
    name="${target#*/}"
    url="$(repo_url "$repo")"
    [ -n "$url" ] || die "unknown repo '$repo'"
    old_rev="$(jq -r --arg r "$repo" --arg n "$name" '.[$r].extensions[$n].rev // empty' "$db")"
    old_hash="$(jq -r --arg r "$repo" --arg n "$name" '.[$r].extensions[$n].hash // empty' "$db")"
    pinned="$(jq -r --arg r "$repo" --arg n "$name" '.[$r].extensions[$n].pinned // false' "$db")"
    [ -n "$old_rev" ] || die "unknown extension '$repo/$name'"

    if [ "$pinned" = "true" ]; then
      printf '%-10s %-18s held at %s\n' "$repo" "$name" "${old_rev:0:8}"
      continue
    fi

    local new_rev
    new_rev="$(resolve_head "$url")"

    if [ "$new_rev" = "$old_rev" ] && [ -n "$old_hash" ]; then
      printf '%-10s %-18s up to date (%s)\n' "$repo" "$name" "${old_rev:0:8}"
      continue
    fi

    local new_hash
    if ! new_hash="$(prefetch "$url" "$name" "$new_rev")"; then
      printf '%-10s %-18s FAILED, keeping %s\n' "$repo" "$name" "${old_rev:0:8}" >&2
      failed=$((failed + 1))
      continue
    fi

    jq_set --arg r "$repo" --arg n "$name" --arg rev "$new_rev" --arg hash "$new_hash" \
      '.[$r].extensions[$n].rev = $rev | .[$r].extensions[$n].hash = $hash'

    if [ "$new_hash" = "$old_hash" ]; then
      printf '%-10s %-18s %s -> %s (contents unchanged)\n' \
        "$repo" "$name" "${old_rev:0:8}" "${new_rev:0:8}"
    else
      printf '%-10s %-18s %s -> %s\n' "$repo" "$name" "${old_rev:0:8}" "${new_rev:0:8}"
      changed=$((changed + 1))
    fi
  done

  echo
  echo "$changed extension(s) changed, $failed failed"
  [ "$failed" -eq 0 ]
}

cmd_add() {
  local repo="${1:-}" name="${2:-}" rev="${3:-}"
  [ -n "$repo" ] && [ -n "$name" ] || die "usage: $(basename "$0") add <repo> <name> [rev]"

  local url
  url="$(repo_url "$repo")"
  [ -n "$url" ] || die "unknown repo '$repo'"
  [ -z "$rev" ] && rev="$(resolve_head "$url")"

  local hash
  hash="$(prefetch "$url" "$name" "$rev")"
  jq_set --arg r "$repo" --arg n "$name" --arg rev "$rev" --arg hash "$hash" \
    '.[$r].extensions[$n] = {rev: $rev, hash: $hash} | .[$r].extensions |= (to_entries | sort_by(.key) | from_entries)'

  echo "added $repo/$name at ${rev:0:8}"
}

cmd_remove() {
  local repo="${1:-}" name="${2:-}"
  [ -n "$repo" ] && [ -n "$name" ] || die "usage: $(basename "$0") remove <repo> <name>"
  jq -e --arg r "$repo" --arg n "$name" '.[$r].extensions | has($n)' "$db" >/dev/null ||
    die "unknown extension '$repo/$name'"
  jq_set --arg r "$repo" --arg n "$name" 'del(.[$r].extensions[$n])'
  echo "removed $repo/$name"
}

case "${1:-update}" in
  update)
    shift || true
    cmd_update "$@"
    ;;
  add)
    shift
    cmd_add "$@"
    ;;
  remove)
    shift
    cmd_remove "$@"
    ;;
  *)
    die "usage: $(basename "$0") {update [<repo>[/<name>]...] | add <repo> <name> [rev] | remove <repo> <name>}"
    ;;
esac
