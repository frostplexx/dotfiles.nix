#!/usr/bin/env bash
full="$1/$2"

# Colors
BOLD="\033[1m"
DIM="\033[2m"
RESET="\033[0m"
GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[33m"
CYAN="\033[36m"
BLUE="\033[34m"

cols=$(tput cols 2>/dev/null || echo 80)
half=$((cols / 2 - 2))

header() {
	local icon="$1"
	local title="$2"
	local color="$3"
	echo -e "${color}${BOLD}${icon}  ${title}${RESET}"
	echo -e "${DIM}$(printf '─%.0s' $(seq 1 $half))${RESET}"
}

header "󰉋" "Files" "$BLUE"
eza --level=1 --color=always "$full" 2>/dev/null |
	cut -c1-$half |
	head -15 ||
	ls "$full" | cut -c1-$half | head -15

echo
header "" "Git Status" "$GREEN"
git_status=$(git -C "$full" status --short 2>/dev/null)
if [ -z "$git_status" ]; then
	echo -e "  ${DIM}Clean${RESET}"
else
	echo "$git_status" | while IFS= read -r line; do
		xy="${line:0:2}"
		file="${line:3}"
		case "$xy" in
		M* | *M) echo -e "  ${YELLOW}  ${xy}${RESET}  ${file}" ;;
		A* | *A) echo -e "  ${GREEN}  ${xy}${RESET}  ${file}" ;;
		D* | *D) echo -e "  ${RED}  ${xy}${RESET}  ${file}" ;;
		\?\?) echo -e "  ${DIM}  ${xy}${RESET}  ${file}" ;;
		*) echo -e "  ${CYAN}  ${xy}${RESET}  ${file}" ;;
		esac
	done
fi

echo
header "" "Unpushed Commits" "$YELLOW"
unpushed=$(git -C "$full" log --branches --not --remotes --oneline 2>/dev/null | head -10)
if [ -z "$unpushed" ]; then
	echo -e "  ${DIM}Up to date${RESET}"
else
	echo "$unpushed" | while IFS= read -r line; do
		echo -e "  ${CYAN} ${RESET} ${line}"
	done
fi
