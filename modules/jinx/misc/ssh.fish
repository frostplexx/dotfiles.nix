#!/usr/bin/env fish

set -g ssh_hosts_file ~/.ssh/hosts

function _create_hosts_file -a name url port
    # Remove ssh:// prefix
    set -l cleaned (string replace -r '^ssh://' '' $url)

    # Split into user and hostname
    set -l user_host (string split '@' $cleaned)
    set -l user $user_host[1]
    set -l host_port $user_host[2]

    # Check if port is embedded in hostname (host:port format)
    set -l host_parts (string split ':' $host_port)
    set -l host $host_parts[1]
    
    # Use embedded port if present, otherwise use provided port parameter
    if test (count $host_parts) -gt 1
        set port $host_parts[2]
    end

    echo "Host $name" >>$ssh_hosts_file
    echo "    HostName \"$host\"" >>$ssh_hosts_file
    echo "    User $user" >>$ssh_hosts_file
    
    # Add port configuration if it's not the default SSH port (22)
    if test -n "$port" -a "$port" != "22"
        echo "    Port $port" >>$ssh_hosts_file
    end
    
    echo "" >>$ssh_hosts_file
end

function generate_ssh_hosts
    set -l items (op item list --tags ssh --format json | jq -r '.[] | @base64')

    # Clear previous content
    echo -n "" >$ssh_hosts_file

    echo "Generating..."
    for item in $items
        set -l _item (echo $item | base64 --decode | jq -r '.id, .title')
        set -l id $_item[1]
        set -l name $_item[2]
        # Try to get URL field (check "url", "Url", and "URL" labels)
        set -l url (op item get $id --fields label=url 2>/dev/null)
        if test -z "$url"
            set url (op item get $id --fields label=Url 2>/dev/null)
        end
        if test -z "$url"
            set url (op item get $id --fields label=URL 2>/dev/null)
        end
        
        # Try to get port field (check both "port" and "Port" labels)
        set -l port (op item get $id --fields label=port 2>/dev/null)
        if test -z "$port"
            set port (op item get $id --fields label=Port 2>/dev/null)
        end
        
        _create_hosts_file $name $url $port
    end

    echo Done
end

generate_ssh_hosts
