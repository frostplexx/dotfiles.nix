function wololo
    set -g HOST "up.int.kuipr.de"
    
    # Open Tailscale
    if not pgrep -x Tailscale >/dev/null
        echo "Connecting to tailnet..."
        open -g -a Tailscale
        # Connect to tailnet
        tailscale up
        # Wait until it connected
        tailscale wait
    end
    
    set -g identity (op read "op://Personal/UpSnap/email")
    set -g password (op read "op://Personal/UpSnap/password")
    
    set -g jwt (curl -s -X POST "https://$HOST/api/collections/_superusers/auth-with-password" -H "Content-Type: application/json" -d "{\"identity\":\"$identity\",\"password\":\"$password\"}" | jq -r '.token')
    
    if test -z "$jwt"
        echo "Auth token is empty. Failed to authenticate. Exiting."
        exit 1
    end
    
    set -g devices (curl -s -X GET "https://$HOST/api/collections/devices/records" -H "Authorization: Bearer $jwt")
    
    set -g selected (echo $devices | jq -r '.items[].name' | fzf)
    
    if test -z "$selected"
        exit 0
    end
    
    set -g device_id (echo $devices | jq -r --arg name "$selected" '.items[] | select(.name == $name) | .id')
    
    echo "Booting: $selected ($device_id)"
    
    
    curl -s -X GET "https://$HOST/api/upsnap/wake/$device_id" -H "Authorization: Bearer $jwt" > /dev/null
    
    while true 
        set -l device_status (curl -s -X GET "https://$HOST/api/collections/devices/records/$device_id" -H "Authorization: Bearer $jwt" | jq -r ".status")
    
        if test "$device_status" = "online"
            echo "$selected is online"
            break
        end
    
        sleep 1
    end
end
