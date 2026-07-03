---
name: ask
description: "Answer questions about the current codebase. Use whenever the user asks how something works, where something is defined, what calls what, why code is structured a certain way, or any 'where/how/why/what' question about existing code. Read-only: never edits files. Every claim cited with file:line."
---

# Ask

Answer questions about the codebase. Read-only skill: never create, edit, or delete files. If the answer implies a change, describe it — do not make it.

## Rules

1. **Cite everything.** Every factual claim about the code carries a `path/to/file.ext:LINE` (or `:START-END` range) citation. No citation → don't state it. If unsure where something lives, search (`grep`/`rg`/glob) until found or report not found.
2. **Read before answering.** Never answer from assumption about what code "probably" does. Open the actual file. If the question spans multiple files, trace the actual call chain and cite each hop.
3. **Verified vs inferred.** Separate what the code demonstrably does from interpretation. Mark inference explicitly: "inferred: ..." Interpretation without code backing is a guess — label it as one.
4. **Answer the question asked.** No unsolicited refactoring suggestions, no "you might also want to...". User asked a question; deliver the answer.
5. **Teach the search.** After answering, include a one-line "how to find this yourself" — the grep pattern or entry point that leads to the answer. Builds the user's own navigation skill instead of replacing it.

## Answer format

- Direct answer first, 1-3 sentences.
- Evidence: relevant code excerpt(s) with `file:line` citations. Quote the minimum lines needed.
- Call chain if relevant: `entry (a.py:12) → handler (b.py:88) → db (c.py:301)`.
- `Find it yourself:` one grep/navigation hint.
- If the question has no answer in the code (config decided at runtime, external service, missing code): say so explicitly rather than speculating.

## Example

Q: "Where do we validate the JWT?"

A: Validation happens in the auth middleware, not the route handlers.

- `src/middleware/auth.ts:34-51` — `verifyToken()` checks signature and expiry via `jsonwebtoken.verify`.
- Wired in at `src/app.ts:22` — applied to all `/api/*` routes.
- Refresh tokens bypass this path: separate check at `src/routes/refresh.ts:18`.

Find it yourself: `rg "jwt|verify" src/middleware/`
