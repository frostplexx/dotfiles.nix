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
