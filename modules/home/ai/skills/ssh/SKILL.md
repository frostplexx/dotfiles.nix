---
name: ssh
description: "Connect to remote servers through ssh for debugging purposes. Use whenever the user mentions SSH, a remote server, hostname, IP address, user@host string, debugging a remote machine, running commands on a server, checking server status, deploying, file transfer, bastion/jump hosts, port forwarding, tunnels, or accessing internal/database services behind a VPN or bastion."
---

# SSH

Single script multiplexed over a persistent control socket.

**Script:** `~/.agents/skills/ssh/scripts/ssh-skill.sh`

**Workflow:** `list` → ask → `connect` → `exec` (repeat) → `disconnect`

---

## Commands

```
list                  # hosts from ~/.ssh/hosts
connect <host> [user] [port]
connect <user@host>[:port]    # same, parsed automatically
exec    <user@host> "<cmd>"   # runs through existing socket
disconnect <user@host>        # tears down master
```

- `connect` spawns a background multiplexing master (`-f -N -M -S`). Second
  connection onward uses the existing auth — no re-prompt.
- `exec` fails if no master socket exists. Never fall back to direct ssh.
- Wrap compound commands in one quoted string: `"tail -100 log | grep ERROR"`.
- Each `exec` is a separate session through the same master.

---

## ⚠️  Write commands — explicit consent mandatory

Any command that writes, mutates, deletes, restarts, or installs requires user
confirmation of the **exact command string** before running. This includes:
`rm`, `dd`, `mv`, `cp`, `chmod`, `chown`, `>`, `>>`, `sed -i`, `apt install`,
`systemctl restart/*stop/*start`, `reboot`, `shutdown`, `kill`, `useradd`,
`docker rm/*kill/*compose down`, `curl -o` + exec, and any inline edit flag.

Rules:
- One confirmation per write. No batching.
- No `&`, `nohup`, `tmux`, `screen`, `cron` to defer writes.
- Prefer dry-run flags (`--dry-run`, `-i`, `-n`) when available.
- User pasting the exact command themselves counts as consent — still flag if
  obviously dangerous.
