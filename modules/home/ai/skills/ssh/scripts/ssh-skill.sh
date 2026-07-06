#!/bin/bash

CONTROL_SOCKET="~/.ssh/ctl/%r@%h:%p"


function list_hosts() {
    cat ~/.ssh/hosts | grep "Host " | cut -d " " -f 2 | sort
}


# connect to a host as a background daemon (multiplexing master)
# subsequent exec calls reuse this connection via the control socket
function connect_host() {
    local raw="$1"
    local user_or_port="$2"
    local port="$3"

    if [[ -z "$raw" ]]; then
        echo "Error: Host is required."
        exit 1
    fi

    local user=""
    local host="$raw"

    # parse user@host[:port] from first arg; second arg becomes port, not user
    if [[ "$raw" == *@* ]]; then
        user="${raw%%@*}"
        host="${raw#*@}"
        if [[ -n "$user_or_port" ]]; then
            port="$user_or_port"
        fi
    else
        user="$user_or_port"
    fi

    # extract port from host:port notation (embedded port only used if no explicit port given)
    if [[ "$host" == *:* ]]; then
        local embedded_port="${host##*:}"
        host="${host%:*}"
        if [[ -z "$port" ]]; then
            port="$embedded_port"
        fi
    fi

    if [[ -z "$user" ]]; then
        user=$(whoami)
    fi

    if [[ -z "$port" ]]; then
        port=22
    fi

    mkdir -p ~/.ssh/ctl

    ssh -f -N -T -M -S "$CONTROL_SOCKET" \
        -o ControlPersist=10m \
        -o "StrictHostKeyChecking=no" \
        -o "UserKnownHostsFile=/dev/null" \
        -p "$port" "$user@$host"

    echo "Connected to $host as $user on port $port (background master, socket: $CONTROL_SOCKET)"
}


# disconnect from a host by stopping the background master
# cleans up the control socket automatically
function disconnect_host() {
    local connection="$1"

    if [[ -z "$connection" ]]; then
        echo "Error: Connection string (host or user@host) is required."
        exit 1
    fi

    ssh -S "$CONTROL_SOCKET" -O stop "$connection" 2>&1
}


# execute a command on a remote host via the background master connection
# fails if no control socket exists (run 'connect' first)
function exec_command() {
    local connection="$1"
    shift
    local command="$*"

    if [[ -z "$connection" ]]; then
        echo "Error: Connection string (host or user@host) is required."
        exit 1
    fi

    if [[ -z "$command" ]]; then
        echo "Error: Command is required."
        exit 1
    fi

    # verify the control socket is alive before attempting to use it
    ssh -S "$CONTROL_SOCKET" -O check "$connection" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo "Error: No background connection for $connection." >&2
        echo "Run 'connect $connection' first to establish the master session." >&2
        exit 1
    fi

    ssh -S "$CONTROL_SOCKET" \
        -o "StrictHostKeyChecking=no" \
        -o "UserKnownHostsFile=/dev/null" \
        "$connection" "$command"
}



# Parse arguments
if [[ "$1" == "list" ]]; then
    list_hosts
    exit 0
fi

if [[ "$1" == "connect" ]]; then
    connect_host "$2" "$3" "$4"
    exit 0
fi

if [[ "$1" == "exec" ]]; then
    exec_command "$2" "${@:3}"
    exit 0
fi

if [[ "$1" == "disconnect" ]]; then
    disconnect_host "$2"
    exit 0
fi

echo "Usage: $0 {list|connect|exec|disconnect} [args...]"
exit 1

