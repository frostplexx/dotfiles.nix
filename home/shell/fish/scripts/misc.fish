
function clear_dns
    sudo dscacheutil -flushcache; 
    sudo killall -HUP mDNSResponder
end


function cocaine
    # Check current DPMS status
    set status (xset -q | grep 'DPMS is' | awk '{ print $3 }')
    
    # Toggle DPMS based on current status
    if test "$status" = "Enabled"
        xset -dpms
        dunstify 'Screen suspend is disabled.'
    else
        xset +dpms
        dunstify 'Screen suspend is enabled.'
    end
end

function manf
    /usr/bin/man -k . 2>/dev/null | fzf --preview 'man {1}' --preview-window=right:70%:wrap | awk '{print $1}' | xargs man
end
