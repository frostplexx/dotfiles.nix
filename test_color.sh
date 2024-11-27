#!/bin/bash

# Create a test Makefile
cat > Makefile.colors.test << 'EOL'
include Makefile.colors

.PHONY: test-colors

test-colors:
	@echo "=== Basic Colors ==="
	@echo "${BLUE}BLUE Text${RESET}"
	@echo "${GREEN}GREEN Text${RESET}"
	@echo "${RED}RED Text${RESET}"
	@echo "${YELLOW}YELLOW Text${RESET}"
	@echo "${CYAN}CYAN Text${RESET}"
	@echo "${MAGENTA}MAGENTA Text${RESET}"
	
	@echo "\n=== Background Colors ==="
	@echo "${BG_BLUE}BG_BLUE${RESET}"
	@echo "${BG_GREEN}BG_GREEN${RESET}"
	@echo "${BG_RED}BG_RED${RESET}"
	@echo "${BG_YELLOW}BG_YELLOW${RESET}"
	@echo "${BG_CYAN}BG_CYAN${RESET}"
	@echo "${BG_MAGENTA}BG_MAGENTA${RESET}"
	
	@echo "\n=== Text Formatting ==="
	@echo "${BOLD}BOLD Text${RESET}"
	@echo "${DIM}DIM Text${RESET}"
	@echo "${ITALIC}ITALIC Text${RESET}"
	@echo "${UNDERLINE}UNDERLINE Text${RESET}"
	@echo "${BLINK}BLINK Text${RESET}"
	@echo "${REVERSE}REVERSE Text${RESET}"
	@echo "${STRIKE}STRIKE Text${RESET}"
	
	@echo "\n=== Symbols ==="
	@echo "${CHECK} CHECK"
	@echo "${ARROW} ARROW"
	@echo "${WARN} WARN"
	@echo "${ERR} ERR"
	@echo "${INFO_SYMBOL} INFO_SYMBOL"
	
	@echo "\n=== Compound Styles ==="
	@echo "${INFO} INFO Style"
	@echo "${SUCCESS} SUCCESS Style"
	@echo "${ERROR} ERROR Style"
	@echo "${HEADER}HEADER Style${RESET}"
	@echo "${DONE}DONE Style${RESET}"
	@echo "${IMPORTANT}IMPORTANT Style${RESET}"
	@echo "${DEBUG}DEBUG Style${RESET}"
	@echo "${NOTICE}NOTICE Style${RESET}"
	
	@echo "\n=== Real-world Examples ==="
	@echo "${HEADER}Starting build process...${RESET}"
	@echo "${INFO} Compiling main.cpp..."
	@echo "${SUCCESS} Successfully compiled main.cpp"
	@echo "${WARN} Deprecation notice: Using legacy API"
	@echo "${ERROR} Failed to link: missing dependency"
	@echo "${DEBUG} Build hash: abc123${RESET}"
	@echo "${IMPORTANT}Security update required${RESET}"
	@echo "${NOTICE}New version available${RESET}"
EOL

# Save your color definitions to Makefile.colors
mv makefile-colors Makefile.colors

# Instructions for the user
echo "Files created:"
echo "1. Makefile.colors (your color definitions)"
echo "2. Makefile.colors.test (the test makefile)"
echo ""
echo "To test the colors, run:"
echo "make -f Makefile.colors.test test-colors"
