{ pkgs }:

pkgs.mkShell {
  name = "c";
  buildInputs = with pkgs; [
    gcc
    gdb
    gnumake
    cmake
    bear # For generating compilation database
    clang-tools # For clangd LSP
    valgrind
  ];

  shellHook = ''
        if [ -f ~/.zshrc ]; then
          source ~/.zshrc
        fi

        # Initialize project if it doesn't exist
        if [ ! -f "main.c" ]; then
          echo "Creating new C project..."

          # Create main.c with a basic template
          cat > main.c << 'EOL'
    #include <stdio.h>
    #include <stdlib.h>

    int main(int argc, char *argv[]) {
        printf("Hello, World!\n");
        return 0;
    }
    EOL

          # Create a Makefile with common targets
          cat > Makefile << 'EOL'
    # Compiler settings
    CC = gcc
    CFLAGS = -Wall -Wextra -g

    # Directories
    SRC_DIR = .
    BUILD_DIR = build

    # Files
    SRCS = $(wildcard $(SRC_DIR)/*.c)
    OBJS = $(SRCS:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
    TARGET = $(BUILD_DIR)/program

    # Default target
    all: $(BUILD_DIR) $(TARGET)

    # Create build directory
    $(BUILD_DIR):
    	mkdir -p $(BUILD_DIR)

    # Link
    $(TARGET): $(OBJS)
    	$(CC) $(OBJS) -o $(TARGET)

    # Compile
    $(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
    	$(CC) $(CFLAGS) -c $< -o $@

    # Generate compilation database for LSP support
    compile_commands.json: Makefile
    	bear -- make

    # Run the program
    run: all
    	./$(TARGET)

    # Debug with GDB
    debug: all
    	gdb $(TARGET)

    # Memory check with Valgrind
    memcheck: all
    	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(TARGET)

    # Clean build files
    clean:
    	rm -rf $(BUILD_DIR) compile_commands.json

    .PHONY: all run debug memcheck clean
    EOL

          # Create a basic .gitignore
          cat > .gitignore << 'EOL'
    # Build directory
    build/

    # Prerequisites
    *.d

    # Object files
    *.o
    *.ko
    *.obj
    *.elf

    # Linker output
    *.ilk
    *.map
    *.exp

    # Precompiled Headers
    *.gch
    *.pch

    # Libraries
    *.lib
    *.a
    *.la
    *.lo

    # Debug files
    *.dSYM/
    *.su
    *.idb
    *.pdb

    # Editor specific files
    .vscode/
    .idea/
    *.swp
    *.swo

    # Compilation database
    compile_commands.json
    EOL

          # Create build directory
          mkdir -p build

          # Initialize git repository if git is available
          if command -v git >/dev/null 2>&1; then
            git init
          fi

          echo "🎯 C project initialized! Use 'make' to build and './build/program' to run."
          echo "Available make targets:"
          echo "  make       - Build the program"
          echo "  make run   - Build and run the program"
          echo "  make debug - Start GDB debugger"
          echo "  make memcheck - Run Valgrind memory checker"
          echo "  make clean - Remove build files"
        fi

        export C_SHELL=1

        echo "🔧 C development environment activated!"
  '';
}
