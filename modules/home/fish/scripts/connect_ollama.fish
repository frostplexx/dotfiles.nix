function connect_ollama 
    # Check if eduVPN is running and connect if not connected
    if ! pgrep -x "eduVPN" > /dev/null
        echo "Starting eduVPN..."
        # Wait for eduVPN to establish connection (adjust sleep time as needed)
        open -a "eduVPN"
    end
    # Port is on 11434
    echo "Connecting to Ollama on port 11434..."
    ssh -N -L 11434:localhost:11434 PLAI_GPU_Students
end
