###############################################################################
# Color and formatting definitions for make output using xterm-256 colors
#
# Colors:
# - BLUE:    Royal blue for information and headers (color 69)
# - GREEN:   Emerald for success messages (color 78)
# - RED:     Crimson for error messages (color 160)
# - YELLOW:  Gold for warnings (color 178)
# - CYAN:    For additional highlighting (color 37)
# - MAGENTA: For special notices (color 165)
#
# Background colors are also available with BG_ prefix
#
# Symbols:
# - ✓ (CHECK):  Success
# - → (ARROW):  Progress/Info
# - ! (WARN):   Warning
# - ✗ (ERR):    Error
# - ℹ (INFO):   Information
#
# Usage:
# echo "${INFO} Starting process..."
# echo "${SUCCESS} Process complete!"
# echo "${ERROR} Process failed!"
# echo "${WARN} Please verify..."
###############################################################################

COLOR_PREFIX := $(shell printf '\033[')

# Foreground Colors (xterm-256)
BLUE := ${COLOR_PREFIX}38;5;69m
GREEN := ${COLOR_PREFIX}38;5;78m
RED := ${COLOR_PREFIX}38;5;160m
YELLOW := ${COLOR_PREFIX}38;5;178m
CYAN := ${COLOR_PREFIX}38;5;37m
MAGENTA := ${COLOR_PREFIX}38;5;165m

# Background Colors (xterm-256)
BG_BLUE := ${COLOR_PREFIX}48;5;69m
BG_GREEN := ${COLOR_PREFIX}48;5;78m
BG_RED := ${COLOR_PREFIX}48;5;160m
BG_YELLOW := ${COLOR_PREFIX}48;5;178m
BG_CYAN := ${COLOR_PREFIX}48;5;37m
BG_MAGENTA := ${COLOR_PREFIX}48;5;165m

# Text Formatting
BOLD := ${COLOR_PREFIX}1m
DIM := ${COLOR_PREFIX}2m
ITALIC := ${COLOR_PREFIX}3m
UNDERLINE := ${COLOR_PREFIX}4m
BLINK := ${COLOR_PREFIX}5m
REVERSE := ${COLOR_PREFIX}7m
HIDDEN := ${COLOR_PREFIX}8m
STRIKE := ${COLOR_PREFIX}9m

# Reset
RESET := ${COLOR_PREFIX}0m

# Symbols with Colors
CHECK := ${GREEN}✓${RESET}
ARROW := ${BLUE}→${RESET}
WARN := ${YELLOW}!${RESET}
ERR := ${RED}✗${RESET}
INFO_SYMBOL := ${CYAN}ℹ${RESET}

# Compound Styles
INFO := ${ARROW}
SUCCESS := ${CHECK}
ERROR := ${ERR}
HEADER := ${BOLD}${BLUE}
DONE := ${BOLD}${GREEN}
IMPORTANT := ${BOLD}${BG_YELLOW}${RED}
DEBUG := ${DIM}${CYAN}
NOTICE := ${MAGENTA}${BOLD}

# Example Usage:
# echo "${HEADER}Building Project${RESET}"
# echo "${INFO} Compiling sources..."
# echo "${SUCCESS} Build complete!"
# echo "${ERROR} Build failed!"
# echo "${WARN} Missing dependencies..."
# echo "${IMPORTANT}Critical Notice${RESET}"
# echo "${DEBUG}Debug information${RESET}"
# echo "${NOTICE}Special announcement${RESET}"
