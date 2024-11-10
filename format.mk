# Documentation
###############################################################################
# Color and formatting definitions for make output
#
# Colors:
# - BLUE:   Information and headers
# - GREEN:  Success messages
# - RED:    Error messages
# - YELLOW: Warnings
#
# Symbols:
# - ✓ (CHECK):  Success
# - → (ARROW):  Progress/Info
# - ! (WARN):   Warning
# - ✗ (ERR):    Error
#
# Usage:
# echo "${INFO} Starting process..."
# echo "${SUCCESS} Process complete!"
# echo "${ERROR} Process failed!"
# echo "${WARN} Please verify..."
###############################################################################

COLOR_PREFIX := $(shell printf '\033[')
BLUE := ${COLOR_PREFIX}34m
GREEN := ${COLOR_PREFIX}32m
RED := ${COLOR_PREFIX}31m
YELLOW := ${COLOR_PREFIX}33m
BOLD := ${COLOR_PREFIX}1m
RESET := ${COLOR_PREFIX}0m

CHECK := ${GREEN}✓${RESET}
ARROW := ${BLUE}→${RESET}
WARN := ${YELLOW}!${RESET}
ERR := ${RED}✗${RESET}

INFO := ${ARROW}
SUCCESS := ${CHECK}
ERROR := ${ERR}
HEADER := ${BOLD}${BLUE}
DONE := ${BOLD}${GREEN}
