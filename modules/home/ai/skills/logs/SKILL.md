---
name: logs
description: "Parse, explain, and triage error logs, stack traces, crash dumps, CI failure output, or any pasted log text. Use whenever the user pastes log output, a traceback, compiler errors, or asks 'what does this error mean'. Explains root signal vs noise; does not fix code unless asked."
---

# Logs

Turn raw log output into a diagnosis. Explain-first skill: the deliverable is understanding, not a patch. Offer next steps; implement only on explicit request.

## Method

1. **Find the root event.** Logs bury the cause under consequences. Locate the *first* abnormal line chronologically — later errors are usually cascade. For stack traces: root cause frame (deepest user-code frame), not the outermost wrapper. For chained exceptions (`caused by`, `__cause__`), follow to the end of the chain.
2. **Separate signal from noise.** Explicitly mark which lines matter and which are irrelevant (retries of the same failure, unrelated warnings, framework chatter). Users often fixate on the loudest line, not the important one.
3. **Decode literally, then contextually.** First state what the error message literally means (e.g. `ECONNREFUSED` = nothing listening on that address). Then map to this codebase: which component, triggered by what. If repo access exists, open the cited file:line and quote the failing code.
4. **Timeline for multi-event logs.** When the log covers a sequence (service startup, CI pipeline, request lifecycle), reconstruct order: what succeeded, first failure, what cascaded.
5. **Distinguish confirmed from hypothesis.** The log proves some things; others are inference. Label each. If multiple causes fit the evidence, list them ranked by likelihood with the discriminating check for each ("if X, then `grep Y` will show...").

## Output format

```
## Root event
<the one line/frame that matters, quoted, with literal meaning>

## What happened
<2-5 sentence narrative: trigger → failure → cascade>

## Noise
<lines safe to ignore, one line why>

## Confirmed vs suspected
<what the log proves / what is hypothesis + how to verify each>

## Next step
<single cheapest check or fix direction>
```

Short logs with obvious cause: collapse the format, answer in a few sentences. Don't ceremonialize a missing semicolon.

## Rules

- Never invent log lines or pretend to have seen output that wasn't pasted. Missing context (truncated trace, no timestamps): say what's missing and what it would reveal.
- Ask for the full trace if only the last lines were pasted and the root frame is cut off — that request beats guessing.
- Timestamps present → check for gaps; a 30s hole before a timeout *is* the story.
- Secrets/tokens visible in pasted logs: point them out so the user can rotate them.
