#!/usr/bin/env bash
# ddg.sh - web search and page reading using only curl (plus POSIX text tools).
# Usage:  source /path/to/ddg.sh
#   ddg_search "query" [max_results] [key=value ...]   ranked results: title, URL, snippet
#   ddg_instant "query"                                DuckDuckGo Instant Answer API (raw JSON)
#   ddg_instant_summary "query"                        same, key fields only
#   web_fetch URL [max_chars] [offset]                 page -> readable text, paged
# Requires GNU sed (case-insensitive ranges). Tested with bash 4+.

DDG_UA="${DDG_UA:-Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0}"

_urldecode() {
  sed 's/\\/\\\\/g; s/%\([0-9A-Fa-f][0-9A-Fa-f]\)/\\x\1/g' |
    while IFS= read -r _l || [ -n "$_l" ]; do printf '%b\n' "$_l"; done
}

_unescape() {
  sed -e 's/&nbsp;/ /g' -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' \
      -e "s/&#x27;/'/g" -e "s/&#39;/'/g" -e 's/&#x2F;/\//g' -e 's/&amp;/\&/g'
}

# ---------------------------------------------------------------- search
ddg_search() {
  local q="$1" n="${2:-8}" args=() kv html
  shift; [ $# -gt 0 ] && shift
  for kv in "$@"; do args+=(--data-urlencode "$kv"); done   # e.g. df=w  kl=de-de

  html=$(curl -sS --compressed -A "$DDG_UA" --max-time 20 \
           -H 'Accept-Language: en-US,en;q=0.9' \
           --data-urlencode "q=$q" "${args[@]}" \
           https://html.duckduckgo.com/html/) \
    || { echo "ddg_search: curl failed" >&2; return 1; }

  if printf '%s' "$html" | grep -qi 'anomaly\|captcha\|challenge-form'; then
    echo "ddg_search: DuckDuckGo is rate-limiting/challenging us. Wait 30-60s, then retry once." >&2
    return 2
  fi
  if ! printf '%s' "$html" | grep -q 'result__a'; then
    echo "ddg_search: no results parsed (empty result set or page layout changed)" >&2
    return 3
  fi

  printf '%s' "$html" | tr '\r\n\t' '   ' |
    sed 's/class="result__a"/\n@@R@@/g' | tail -n +2 |
    {
      local i=0 blk url title snip
      while IFS= read -r blk || [ -n "$blk" ]; do
        url=$(printf '%s' "$blk" | sed -n 's/^@@R@@[^>]*uddg=\([^&"]*\).*/\1/p' | _urldecode)
        [ -z "$url" ] && url=$(printf '%s' "$blk" | sed -n 's/^@@R@@ href="\(https\{0,1\}:[^"]*\)".*/\1/p')
        case "$url" in ""|*duckduckgo.com/y.js*) continue ;; esac   # skip ads / empty entries
        title=$(printf '%s' "$blk" | sed 's/^@@R@@[^>]*>//; s/<\/a>.*//; s/<[^>]*>//g' | _unescape)
        snip=$(printf '%s' "$blk" | sed -n 's/.*class="result__snippet"[^>]*>\(.*\)/\1/p' |
               sed 's/<\/a>.*//; s/<[^>]*>//g' | _unescape)
        i=$((i + 1))
        printf '%d. %s\n   %s\n   %s\n\n' "$i" "$title" "$url" "$snip"
        [ "$i" -ge "$n" ] && break
      done
    }
}

# ------------------------------------------------------- instant answers
ddg_instant() {
  curl -sS -G --compressed -A "$DDG_UA" --max-time 15 \
    --data-urlencode "q=$1" -d format=json -d no_html=1 -d skip_disambig=1 -d t=curl-agent \
    https://api.duckduckgo.com/
}

ddg_instant_summary() {
  local j
  j=$(ddg_instant "$1") || return 1
  printf '%s' "$j" |
    grep -o '"\(Heading\|AbstractText\|AbstractURL\|Answer\|Definition\|DefinitionURL\|Text\|FirstURL\)":"\([^"\\]\|\\.\)*"' |
    sed 's/^"\([A-Za-z]*\)":"\(.*\)"$/\1: \2/; s/\\"/"/g' | _unescape | grep -v ': $'
}

# ------------------------------------------------------------ html -> text
_html2text() {
  tr '\r\n\t' '   ' |
    sed 's/<\/\(script\|style\|noscript\|svg\|head\)>/&\n/Ig' |   # keep text that follows a closer
    sed 's/</\n</g' |                                               # one tag per line
    sed -E '/^<(script|style|noscript|svg|head)([ >\/]|$)/I,/^<\/(script|style|noscript|svg|head)>/Id' |
    sed -E 's/^<!--.*//' |
    sed -E 's/^<\/?(p|div|br|hr|li|ul|ol|h[1-6]|tr|table|section|article|header|footer|nav|blockquote|pre|dt|dd)([ \/>][^>]*)?>/@@NL@@/I' |
    sed -E 's/^<[^>]*>//' |
    tr -d '\n' |
    sed 's/@@NL@@/\n/g' |
    _unescape |
    sed -E 's/[[:space:]]+/ /g; s/^ //; s/ $//' |
    awk 'NF'
}

# ------------------------------------------------------------- fetch page
web_fetch() {
  local url="$1" max="${2:-8000}" off="${3:-0}" tmp meta code ctype final total
  tmp=$(mktemp) || return 1
  meta=$(curl -sSL --compressed -A "$DDG_UA" --max-time 30 --max-redirs 5 --max-filesize 5000000 \
           -H 'Accept: text/html,application/xhtml+xml,text/plain;q=0.9,*/*;q=0.5' \
           -H 'Accept-Language: en-US,en;q=0.9' \
           -o "$tmp" -w '%{http_code}|%{content_type}|%{url_effective}' "$url") \
    || { echo "web_fetch: curl failed for $url" >&2; rm -f "$tmp"; return 1; }
  IFS='|' read -r code ctype final <<<"$meta"
  echo "[HTTP $code | $ctype | $final]"
  case "$code" in 2??) ;; *) echo "web_fetch: non-2xx status, try another source" >&2; rm -f "$tmp"; return 1 ;; esac

  case "$ctype" in
    *html*|*xml*)                         _html2text <"$tmp" >"$tmp.txt" ;;
    text/*|*json*|*javascript*)           cp "$tmp" "$tmp.txt" ;;
    *) echo "[binary content ($ctype), not displayed]"; rm -f "$tmp" "$tmp.txt"; return 0 ;;
  esac
  total=$(wc -c <"$tmp.txt")
  tail -c +"$((off + 1))" "$tmp.txt" | head -c "$max"
  echo
  echo "[chars $off-$((off + max < total ? off + max : total)) of $total; next page: web_fetch '$url' $max $((off + max))]"
  rm -f "$tmp" "$tmp.txt"
}
