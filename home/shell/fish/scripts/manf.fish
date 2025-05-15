
function manf
    /usr/bin/man -k . 2>/dev/null | fzf --preview 'man {1}' --preview-window=right:70%:wrap | awk '{print $1}' | xargs man
end
