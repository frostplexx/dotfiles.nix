{ pkgs }:
pkgs.mkShell {
  name = "python";
  buildInputs = with pkgs; [
    python3
    python3Packages.pip
    python3Packages.virtualenv
    poetry
  ];

  shellHook = ''
    # Inherit existing environment
    source ~/.zshrc 2>/dev/null || true

    # Python-specific configuration
    export PYTHONPATH="$PWD/${pkgs.python3}/lib/python3.*/site-packages:$PYTHONPATH"

    # Create and activate virtualenv if it doesn't exist
    if [ ! -d ".venv" ]; then
      python -m venv .venv
    fi
    source .venv/bin/activate

    echo "Python development environment activated!"
  '';
}
