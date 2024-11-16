# shells/python.nix
{pkgs}:
pkgs.mkShell {
  name = "python";
  buildInputs = with pkgs; [
    python3
    python3Packages.pip
  ];

  shellHook = ''

    # Create and activate virtualenv if it doesn't exist
    if [ ! -d ".venv" ]; then
      echo "Creating Python virtual environment..."
      python -m venv .venv
    fi

    source .venv/bin/activate
    echo "🐍 Python environment activated!"
  '';
}
