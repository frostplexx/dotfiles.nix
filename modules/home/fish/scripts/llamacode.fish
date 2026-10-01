function llamacode
    set -l fzf_opts \
        --height 100% \
        --layout reverse \
        --border rounded \
        --prompt "model> " \
        --pointer "▶" \
        --marker "✓" \
        --info inline \
        --exact \
        --preview "ollama show {1}" \
        --preview-window right:60%:wrap \
        --bind "ctrl-/:toggle-preview" \
        --bind "ctrl-j:down,ctrl-k:up" \
        --color "header:italic:underline,pointer:green,marker:yellow"
    
    set -l header (ollama list | head -1)
    set -l selection (ollama list | tail -n +2 | fzf --header "$header" $fzf_opts)
    set -l selected_model (string split -f1 ' ' $selection)
    echo "Selected model: $selected_model"
    
    
    ollama launch claude --model $selected_model -y

end
