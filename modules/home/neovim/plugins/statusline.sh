#!/usr/bin/env bash
#
# Claude Code status line, styled like a Neovim lualine modeline.
# Left:  colored vim-mode pill (the signature IDE look)
# Mid:   model, context progress bar, git diff stats, branch/worktree, PR badge
# Right: rate limits, session cost, directory
#
# Receives session JSON on stdin (see https://code.claude.com/docs/en/statusline).

# ── Catppuccin Mocha palette ──────────────────────────────────────────────
# Foregrounds
RED="\033[38;2;243;139;168m"
PEACH="\033[38;2;250;179;135m"
YELLOW="\033[38;2;249;226;175m"
GREEN="\033[38;2;166;227;161m"
TEAL="\033[38;2;148;226;213m"
BLUE="\033[38;2;137;180;250m"
MAUVE="\033[38;2;203;166;247m"
LAVENDER="\033[38;2;180;190;254m"
PINK="\033[38;2;245;194;231m"
SUBTEXT0="\033[38;2;166;173;200m"
OVERLAY1="\033[38;2;127;132;156m"
# Dark foreground for text drawn on top of a colored pill
BASE_FG="\033[38;2;30;30;46m"
RESET="\033[0m"

# Powerline round caps (require a Nerd Font)
CAP_L=""
CAP_R=""

# ── Parse session JSON in a single jq pass (keep the script fast) ──────────
# Fields are joined with the ASCII Unit Separator (0x1F): unlike tab, it is a
# non-whitespace delimiter, so `read` preserves empty fields instead of
# collapsing them and shifting every column.
input=$(cat)
IFS=$'\037' read -r \
  model cwd output_style cost used_pct five_hour_pct seven_day_pct \
  effort vim_mode lines_added lines_removed pr_num pr_url pr_state \
  git_worktree transcript \
  <<EOF
$(printf '%s' "$input" | jq -r '[
  (.model.display_name // .model.id // "?"),
  (.workspace.current_dir // "."),
  (.output_style.name // ""),
  (.cost.total_cost_usd // 0),
  (.context_window.used_percentage // ""),
  (.rate_limits.five_hour.used_percentage // ""),
  (.rate_limits.seven_day.used_percentage // ""),
  (.effort.level // ""),
  (.vim.mode // ""),
  (.cost.total_lines_added // 0),
  (.cost.total_lines_removed // 0),
  (.pr.number // ""),
  (.pr.url // ""),
  (.pr.review_state // ""),
  (.workspace.git_worktree // ""),
  (.transcript_path // "")
] | map(tostring) | join("\u001f")')
EOF

# Effort fallback: read the configured default when the session omits it
if [ -z "$effort" ] && [ -f "$HOME/.claude/settings.json" ]; then
  effort=$(jq -r '.effortLevel // empty' "$HOME/.claude/settings.json" 2>/dev/null)
fi

# Context % fallback: derive from the transcript when the harness omits it
if [ -z "$used_pct" ] && [ -n "$transcript" ] && [ -f "$transcript" ]; then
  toks=$(grep '"usage"' "$transcript" 2>/dev/null | tail -1 |
    jq -r '(.message.usage.input_tokens // 0)
         + (.message.usage.cache_read_input_tokens // 0)
         + (.message.usage.cache_creation_input_tokens // 0)' 2>/dev/null)
  if [ -n "$toks" ] && [ "$toks" -gt 0 ] 2>/dev/null; then
    case "$model" in *1M*) lim=1000000 ;; *) lim=200000 ;; esac
    used_pct=$((toks * 100 / lim))
  fi
fi

sep="${OVERLAY1}│${RESET}"
out=""

# ── Mode pill (lualine-style) ─────────────────────────────────────────────
# When Claude's vim input mode is active, color the pill by mode; otherwise
# fall back to a model pill so the bar always opens with an IDE-like segment.
case "$vim_mode" in
  NORMAL) pill_rgb="137;180;250"; pill_text=" NORMAL " ;;
  INSERT) pill_rgb="166;227;161"; pill_text=" INSERT " ;;
  VISUAL*) pill_rgb="203;166;247"; pill_text=" ${vim_mode} " ;;
  REPLACE) pill_rgb="243;139;168"; pill_text=" REPLACE " ;;
  "") pill_rgb="137;180;250"; pill_text=" 󰧑 ${model} " ;;
  *) pill_rgb="148;226;213"; pill_text=" ${vim_mode} " ;;
esac
pill_fg="\033[38;2;${pill_rgb}m"
pill_bg="\033[48;2;${pill_rgb}m"
out="${pill_fg}${CAP_L}${pill_bg}${BASE_FG}${pill_text}${RESET}${pill_fg}${CAP_R}${RESET}"

# Model (only as its own segment when the pill is showing a vim mode)
if [ -n "$vim_mode" ]; then
  out="${out} ${BLUE}󰧑 ${model}${RESET}"
fi

# Output style (only when non-default)
if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
  out="${out} ${sep} ${LAVENDER}${output_style}${RESET}"
fi

# Effort level
if [ -n "$effort" ]; then
  out="${out} ${sep} ${TEAL}󰓅 ${effort}${RESET}"
fi

# ── Context window: progress bar + percentage ─────────────────────────────
if [ -n "$used_pct" ]; then
  pct=$(printf "%.0f" "$used_pct")
  if [ "$pct" -lt 50 ]; then
    ctx_color=$GREEN
  elif [ "$pct" -lt 75 ]; then
    ctx_color=$YELLOW
  elif [ "$pct" -lt 90 ]; then
    ctx_color=$PEACH
  else
    ctx_color=$RED
  fi
  width=10
  filled=$((pct * width / 100))
  [ "$filled" -gt "$width" ] && filled=$width
  empty=$((width - filled))
  bar=""
  [ "$filled" -gt 0 ] && printf -v fill "%${filled}s" && bar="${fill// /▓}"
  [ "$empty" -gt 0 ] && printf -v pad "%${empty}s" && bar="${bar}${pad// /░}"
  out="${out} ${sep} ${ctx_color}󰋊 ${bar} ${pct}%${RESET}"
fi

# ── Source-control diff stats (IDE gutter summary) ────────────────────────
if [ "${lines_added:-0}" -gt 0 ] 2>/dev/null || [ "${lines_removed:-0}" -gt 0 ] 2>/dev/null; then
  out="${out} ${sep} ${GREEN}+${lines_added}${RESET} ${RED}-${lines_removed}${RESET}"
fi

# ── Git branch + dirty count (+ worktree) ─────────────────────────────────
if [ -d "$cwd" ]; then
  git_branch=$(cd "$cwd" 2>/dev/null && git branch --show-current 2>/dev/null)
  if [ -n "$git_branch" ]; then
    git_dirty=$(cd "$cwd" 2>/dev/null && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    if [ "$git_dirty" -gt 0 ]; then
      out="${out} ${sep} ${PEACH} ${git_branch} ${OVERLAY1}●${git_dirty}${RESET}"
    else
      out="${out} ${sep} ${PEACH} ${git_branch}${RESET}"
    fi
    [ -n "$git_worktree" ] && out="${out} ${PINK} ${git_worktree}${RESET}"
  fi
fi

# ── Pull request badge (clickable via OSC 8) ──────────────────────────────
if [ -n "$pr_num" ]; then
  case "$pr_state" in
    approved) pr_color=$GREEN ;;
    changes_requested) pr_color=$RED ;;
    pending) pr_color=$YELLOW ;;
    draft) pr_color=$OVERLAY1 ;;
    *) pr_color=$MAUVE ;;
  esac
  if [ -n "$pr_url" ]; then
    out="${out} ${sep} ${pr_color}\033]8;;${pr_url}\a #${pr_num}\033]8;;\a${RESET}"
  else
    out="${out} ${sep} ${pr_color} #${pr_num}${RESET}"
  fi
fi

# ── Rate limits (5h / 7d), if available ───────────────────────────────────
if [ -n "$five_hour_pct" ] || [ -n "$seven_day_pct" ]; then
  out="${out} ${sep} ${PINK}󱫋${RESET}"
  for pair in "5h:$five_hour_pct" "7d:$seven_day_pct"; do
    label="${pair%%:*}"
    val="${pair#*:}"
    [ -z "$val" ] && continue
    r=$(printf "%.0f" "$val")
    if [ "$r" -lt 75 ]; then
      lc=$GREEN
    elif [ "$r" -lt 90 ]; then
      lc=$YELLOW
    else
      lc=$RED
    fi
    out="${out} ${lc}${label}:${r}%${RESET}"
  done
fi

# ── Session cost ──────────────────────────────────────────────────────────
out="${out} ${sep} ${GREEN}\$$(printf "%.2f" "$cost")${RESET}"

# ── Directory ─────────────────────────────────────────────────────────────
out="${out} ${sep} ${SUBTEXT0} $(basename "$cwd")${RESET}"

printf "%b" "$out"
