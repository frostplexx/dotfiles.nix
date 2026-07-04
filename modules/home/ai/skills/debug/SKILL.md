---
name: debug
description: "Systematic debugging methodology for any bug, error, crash, test failure, or unexpected behavior. Use this skill whenever the user reports something broken, not working, failing, crashing, throwing an error or exception, producing wrong output, behaving flakily, hanging, or leaking memory — even if they don't say the word 'debug'. Also use when the user pastes a stack trace, error message, or failing test output, or asks why code is behaving unexpectedly. Prevents shotgun debugging: enforces reproduce, isolate, hypothesize, verify, fix, prove."
---

# Debug

A disciplined debugging loop. The goal is to find the *actual* cause before changing any code. Most wasted debugging time comes from fixing symptoms, guessing, or changing several things at once — this skill exists to prevent that.

## Core loop

Work through these phases in order. Do not skip ahead to writing a fix.

### 1. Reproduce

Before anything else, get a reliable reproduction.

- Run the failing command/test yourself if possible. Capture exact output, exit codes, and stack traces.
- If you can't run it, ask the user for: exact command, full error output (not a paraphrase), environment (OS, language/runtime version, dependency versions), and what changed recently.
- Reduce to the smallest reproduction you can: fewest inputs, fewest steps, minimal data. A 5-line repro is worth an hour of staring at a 5000-line codebase.
- If the bug is intermittent, find what makes it more likely (load, timing, ordering, specific data) before proceeding. Run it in a loop if needed: `for i in $(seq 20); do <cmd> || echo "FAILED on run $i"; done`

**Gate: do not move on until you can state exactly how to trigger the bug, or have confirmed it can't be reproduced locally (then rely on logs/telemetry instead).**

### 2. Read the error properly

- Read the *whole* stack trace, bottom-up for the root frame, top-down for entry point. The first line of user code in the trace is usually where to look — not the framework frames.
- Read the error message literally. "Cannot read property 'x' of undefined" means something is undefined — find out *what* and *why it's undefined*, not just where it's accessed.
- Look for a *second* error above/below the reported one. The reported error is often a downstream symptom.
- Check for error causes/chains (`caused by:`, `__cause__`, `.cause`).

### 3. Isolate

Narrow the search space mechanically, not by intuition:

- **Bisect over history**: if it worked before, `git bisect` (see references/git-bisect.md). Fastest tool available when applicable — check for it early.
- **Bisect over code**: comment out / stub half the pipeline, test, repeat. Binary search beats linear reading.
- **Bisect over data**: works with input A, fails with input B → shrink B toward A.
- **Bisect over environment**: works on machine A, fails on machine B → diff versions, env vars, config, locale, timezone.
- Establish the boundary: last known-good point and first known-bad point, in code, time, or data.

### 4. Hypothesize and verify

- State a hypothesis precisely: "X is null at line N because Y returns early when Z" — not "something's wrong with X".
- Predict what evidence would confirm or refute it *before* looking.
- Verify with the cheapest observation: targeted print/log with distinctive markers (`>>> DEBUG state=...`), assertion, debugger breakpoint, or a one-off test. See references/instrumentation.md for language-specific tooling.
- One variable at a time. Never change two things between observations.
- If the hypothesis is refuted, that's progress — record it and form the next one. Keep a short written list of ruled-out causes when the hunt exceeds ~3 hypotheses; prevents circular investigation.
- If evidence contradicts your mental model ("that's impossible"), the model is wrong. Verify assumptions you're most confident about: is the file you're editing actually the one being executed? Is the build stale? Is a cache serving old results? Right branch? Right environment?

### 5. Fix the cause, not the symptom

- The fix should follow *obviously* from the verified cause. If the fix feels like a workaround (`if (x == null) return;` with no understanding of why x is null), the cause isn't found yet.
- Ask: could this same cause produce other bugs elsewhere? Grep for the pattern.
- Keep the fix minimal. Resist refactoring in the same change — separate commit.

### 6. Prove it

- Re-run the original reproduction: bug gone.
- Add a regression test that fails without the fix and passes with it. If tests exist for this area, run the whole suite.
- Remove all debug instrumentation added during the hunt (grep for your markers).
- For intermittent bugs: run the repro loop again (20+ iterations) — one green run proves nothing.

## Report format

When concluding, summarize:

```
## Root cause
<one paragraph: what actually went wrong and why>

## Fix
<what changed and why this addresses the cause>

## Verification
<how it was proven: repro before/after, tests added/run>
```

## Common failure classes — quick checks

When symptoms match these classes, check the cheap causes first:

| Symptom | Check first |
|---|---|
| Works locally, fails in CI/prod | env vars, versions, timezone/locale, file paths, case-sensitive FS, missing files in build |
| Intermittent / flaky | race conditions, test-order dependence, shared state, time-dependent logic, network timeouts |
| Worked yesterday | `git log` since then, dependency updates (lockfile diff), infra/config changes — bisect |
| Off-by-one / wrong result | boundary values (0, 1, empty, max), integer division, inclusive/exclusive ranges, timezone conversions |
| Hangs / freezes | deadlock (grab thread dump/stack sample first, before killing), infinite loop, unresolved await/promise, blocked I/O |
| Memory growth | unbounded caches/collections, listeners never removed, closures retaining scope |
| "Impossible" state | stale build/cache, editing wrong file/branch, multiple installed versions, shadowed names |
| Heisenbug (vanishes when observed) | timing/races — logging changed the schedule; use lower-overhead observation |

## Anti-patterns — do not do these

- Changing code before reproducing the bug.
- Multiple simultaneous changes ("shotgun debugging").
- Fixing where the error *appears* instead of where it *originates*.
- Declaring victory on one green run of a flaky test.
- Adding `try/catch` or null-checks to silence errors without understanding them.
- Trusting comments/docs over observed behavior — instrument and look.
- Deleting the failing test.

## References

- `references/instrumentation.md` — language-specific debuggers, logging, tracing tools (Python, JS/TS, Go, Rust, Java, C/C++, shell). Read when picking observation tooling.
- `references/git-bisect.md` — full git bisect workflow incl. automated `bisect run`. Read when the bug is a regression with a known-good past state.
