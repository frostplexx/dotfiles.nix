#!/bin/sh

# Emit a Program Status Protocol (OSC 7501) report for jinx.
# Usage:
#   status.sh idle|working|done|error "message" [progress]
#   status.sh blocked permission|question|auth "message" [progress]
#
# The report goes to the controlling terminal. Without one this is a no-op.

state=${1:-}
shift 2>/dev/null || true

case "$state" in
    idle|working|done|error)
        msg=${1:-}
        progress=${2:-}
        kind=
        ;;
    blocked)
        kind=${1:-}
        msg=${2:-}
        progress=${3:-}
        ;;
    *)
        exit 0
        ;;
esac

case "$kind" in
    permission|question|auth) ;;
    *) kind= ;;
esac

case "$state" in
    working|blocked) ;;
    *) progress= ;;
esac

case "$progress" in
    [0-9]|[1-9][0-9]|100) ;;
    *) progress= ;;
esac

encode() {
    printf '%s' "$1" \
        | tr '\n\r\t' '   ' \
        | LC_ALL=C tr -d '\001-\037\177' \
        | base64 \
        | LC_ALL=C tr -d '\n\r'
}

{ : >/dev/tty; } 2>/dev/null || exit 0

report="state=$state:app=jinx"
if [ -n "$kind" ]; then
    report="$report:kind=$kind"
fi
if [ -n "$progress" ]; then
    report="$report:progress=$progress"
fi
if [ -n "$msg" ]; then
    report="$report:msg=$(encode "$msg")"
fi

printf '\033]7501;%s\007' "$report" >/dev/tty
