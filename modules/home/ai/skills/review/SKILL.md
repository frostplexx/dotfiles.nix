---
name: review
description: "Review a diff, commit, branch, or file before merge. Use when the user asks to review code, check a PR, look over changes, or asks 'is this ready to merge'. Also enforces comprehension: flags anything the author likely could not have written themselves, plus duplication introduced by AI-generated code."
---

# Review

Pre-merge review with two goals: catch defects, and enforce the rule "never merge code you couldn't have written yourself". Read-only: report findings, don't fix them unless asked afterward.

## Scope

Determine what's under review: `git diff`, `git diff main...HEAD`, staged changes, or named files. State the scope at the top of the review. If nothing is specified and there are no uncommitted changes, ask.

## Checks, in order

1. **Correctness** — logic errors, unhandled edge cases (empty, zero, max, unicode, concurrent), error paths that swallow failures, off-by-one, resource leaks.
2. **Duplication** — new code that copies existing code in the repo instead of reusing it. Actively grep for near-duplicates of new functions/blocks; AI-generated code duplicates at ~8x historical rates (GitClear 2025), so this check is not optional. Report the existing location that should have been reused.
3. **Security** — injected input reaching shell/SQL/HTML, secrets in code, missing validation at trust boundaries. Scale to the diff; don't audit the world.
4. **Tests** — does the change have test coverage for its main path and its edge cases? A bug fix without a regression test gets flagged.
5. **Comprehension flags** — mark hunks that are candidates for "author can't explain this": unusual idioms, dense one-liners, copied-looking boilerplate, dead parameters, imports never used, defensive code with no matching threat. For each, pose one concrete question the author should be able to answer before merging (e.g. "why is this lock needed here?"). Unanswerable question → don't merge, learn first.

## Output format

```
## Review: <scope>

### Blockers
<numbered; each: file:line, what, why it blocks>

### Should fix
<numbered; same format>

### Comprehension check
<questions the author should answer before merge, each tied to file:line>

### Verdict
merge / fix first / don't merge — one sentence why
```

Empty sections: state "none" — silence is ambiguous. Cite every finding with `file:line`. No style nitpicks unless they hide bugs or the user asks; formatter territory stays with the formatter.

## Calibration

Blocker = incorrect behavior, security hole, data loss, or unanswerable comprehension question on core logic. Everything else is "should fix". Don't inflate — a review where everything is a blocker teaches nothing.
