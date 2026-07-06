---
name: ssh
description: "Connect to remote servers through ssh for debugging purposes. Use whenever the user mentions SSH, a remote server, hostname, IP address, user@host string, debugging a remote machine, running commands on a server, checking server status, deploying, file transfer, bastion/jump hosts, port forwarding, tunnels, or accessing internal/database services behind a VPN or bastion."
---

# SSH

Manage persistent SSH connections to remote servers using a multiplexing master
daemon. All commands go through `ssh-skill.sh`.

**Script location:** `/Users/daniel/.agents/skills/ssh/scripts/ssh-skill.sh`

**Workflow:** `list` → ask user → `connect` → `exec` (repeatedly) → `disconnect`

---

## Listing available hosts

```bash
ssh-skill.sh list
```

Output is hostnames from `~/.ssh/hosts`.

**If you are unsure which host is correct, ask the user.** Have them provide
either a hostname or a connection string in `user@host` format.

---

## Connecting (background master)

Before running any commands, establish a background master session:

```bash
ssh-skill.sh connect <host> [user] [port]
```

This opens a **multiplexing master** daemon:

- `-f`: background, terminal is freed immediately
- `-N`: no remote command executed (just holds the tunnel)
- `-T`: no TTY allocated
- `-M -S ~/.ssh/ctl/%r@%h:%p`: control socket for connection sharing
- `ControlPersist=10m`: stays alive 10 min after last client detaches

Defaults: user = `whoami`, port = `22`.

**Security:** Host key checking is disabled (`StrictHostKeyChecking=no`,
`UserKnownHostsFile=/dev/null`). Only use for ephemeral/dev environments.

### Rules

- Always call `connect` before `exec`. `exec` will fail with an error if no
  master session is running.
- If the user provides a full `user@host` string, pass it directly as the
  host argument — the script accepts it.
- If a custom port is needed, pass it as the third argument.

---

## Running commands

```bash
ssh-skill.sh exec <user@host> <command>
```

The command is a single string — quote it if it contains spaces.

Examples:

```bash
ssh-skill.sh exec user@10.0.0.1 "journalctl -u my-service -n 50"
ssh-skill.sh exec server01 "df -h /data"
ssh-skill.sh exec deploy@buildbox "cd /app && docker compose ps"
```

### How it works

1. `exec` checks the control socket is alive via `ssh -O check`
2. If alive, the command runs through the **existing authenticated channel** —
   zero additional auth or key exchange
3. If the socket is missing or the master is dead, `exec` **fails** with a
   message telling you to run `connect` first

### Rules

- **Never fall back to a direct SSH connection** if the master is not running.
  Fail and tell the user to run `connect` first.
- If the command involves pipes, chaining (`&&`, `|`), or multiple statements,
  wrap the whole thing in one quoted string:
  ```bash
  ssh-skill.sh exec user@host "tail -100 /var/log/app.log | grep ERROR | tail -20"
  ```
- To run several independent commands on the same host, call `exec` multiple
  times — each call is a separate session multiplexed through the same master.

---

## Disconnecting

When done, tear down the background master:

```bash
ssh-skill.sh disconnect <user@host>
```

Uses `ssh -O stop` to gracefully terminate the master process. The socket file
is removed automatically.

### When to disconnect

- At the end of a debugging session
- When switching to a different host
- If the user explicitly asks to close the connection
- If the master has been idle and you're starting a new unrelated task

---

## Full lifecycle example

```bash
# 1. List available hosts
ssh-skill.sh list

# 2. Connect to the target
ssh-skill.sh connect deploy@web01

# 3. Run commands
ssh-skill.sh exec deploy@web01 "systemctl status nginx"
ssh-skill.sh exec deploy@web01 "curl -sI localhost:3000 | head -5"
ssh-skill.sh exec deploy@web01 "tail -50 /var/log/nginx/error.log"

# 4. Clean up
ssh-skill.sh disconnect deploy@web01
```

---

## Rules

- Always `list` first if the user hasn't specified a host. Ask if unsure.
- Always `connect` before `exec`. Never skip the connect step.
- Always `disconnect` at the end of the session.
- Never hardcode credentials or hostnames in prompts — the user provides them.
- The connection string format (`user@host`) is used consistently across all
  subcommands.
- If a command produces a large amount of output, pipe through `tail` or
  `head` in the command string rather than dumping everything.
- Use the absolute script path in commands for reliability.
