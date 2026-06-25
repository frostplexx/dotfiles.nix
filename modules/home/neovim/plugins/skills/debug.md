---
description: Structured debugging session — reproduce, isolate, hypothesize, verify loop. Use when user says "debug this", "something's broken", "help me debug", "why isn't X working", or invokes /debug.
---

Run a tight reproduce → isolate → hypothesize → verify loop. Never guess the root cause before you have evidence. One hypothesis at a time.

## Phase 1 — Reproduce

Before touching code:

1. State the **symptom** exactly: what happens vs. what should happen.
2. Identify the **minimal trigger**: what sequence of actions reliably causes it?
3. Check: is it deterministic? Env-dependent? Regression (worked before)?

If can't reproduce → say so. Do not debug a ghost.

## Phase 2 — Isolate

Narrow the blast radius:

- What changed recently? (`git log --oneline -20`, `git diff HEAD~1`)
- Is the bug in *input*, *processing*, or *output*?
- Binary-search the call stack: which layer first sees bad state?
- Eliminate: comment out, stub, or swap components until bug disappears.

Rule: **reduce surface before reading source.** Don't read 500 lines hoping to spot it.

## Phase 3 — Hypothesize

State one falsifiable hypothesis:

> "I think X is happening because Y, so if I change Z, the bug should go away / the log should show W."

If multiple suspects, rank by likelihood × ease of verification. Check cheapest first.

## Phase 4 — Verify

Test the hypothesis with a **targeted probe**, not a broad fix:

- Add a log/assert at the exact suspected point.
- Run the minimal repro case, not the full suite.
- Observe the actual output vs. predicted output.

If hypothesis is wrong → **do not patch around it**. Return to Phase 2 with the new information.

## Phase 5 — Fix

Only after root cause is confirmed:

- Fix the cause, not the symptom.
- Check: does the fix break other paths? Is there a related bug upstream?
- Remove debug instrumentation before committing.

## Common traps to avoid

| Trap | Antidote |
|------|----------|
| Fix before reproduce | Always repro first |
| Multiple hypotheses in one change | One change, one test |
| Reading code instead of running it | Add instrumentation |
| Fixing symptoms | Ask "why does this symptom occur?" |
| Assuming the error message is exact | Trace to the actual throw site |

## Language-specific quick checks

**Nix / home-manager:**
```bash
# Show eval errors with full trace
nix eval .#<attr> --show-trace
# Check what changed
nix store diff-closures /nix/var/nix/profiles/system-{old}-link /nix/var/nix/profiles/system
home-manager news
```

**Shell / Fish:**
```bash
set -x  # trace mode in fish
fish --debug=<category> -c 'your command'
```

**Swift / ObjC (macOS):**
```bash
log stream --predicate 'subsystem == "com.yourapp"' --level debug
# Symbolic breakpoint on exception: objc_exception_throw
```

**Neovim / Lua:**
```lua
:messages          -- see all printed output
:checkhealth       -- plugin/runtime health
vim.notify(vim.inspect(value))  -- dump any value
```

## Output format

After each phase, report:
- **Found:** what you confirmed
- **Ruled out:** what you eliminated
- **Next:** the next probe or fix

Do not present a solution until Phase 4 confirms the root cause.
