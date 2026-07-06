---
name: plan
description: "Create a PLAN.md file with a detailed implementation plan for a feature. Use whenever the user asks to plan, design, think through, architect, or outline an implementation before writing code. The agent creates the plan, presents the path to the user, and waits for approval before any implementation begins."
---

# Plan

Never start implementing a feature without a written plan first. Writing a plan before coding catches blind spots, forces ordering, and separates design from construction.

## Process

### 1. Gather scope

Before writing the plan, clarify:

- What is the feature supposed to do? Surface any ambiguities — don't fill gaps from assumption.
- What constraints exist? (performance, security, backwards compatibility, deployment, team conventions)
- What is explicitly out of scope? Document non-goals to prevent scope creep.
- Are there existing patterns in the codebase this should follow? Point to them.

Ask the user if anything is unclear. If the request is unambiguous, proceed — don't add conversational delay for trivial steps.

### 2. Create the plan

Write a `PLAN.md` file at the project root (or at the root of the relevant workspace/module if the project is a monorepo). The plan must include these sections:

```
# Plan: <Feature Name>

## Overview
<1-3 sentences: what this feature does and why it matters>

## Files changed
<list every file that will be created or modified, with a one-line purpose for each>

## Implementation steps
<numbered steps in order. Each step is one logical change — small enough to review individually, large enough to compose a unit of work. Steps should be executable independently when possible.>

Step 1 — <short title>
- <what changes and why>
- <specifics: new files, functions to add/modify, interfaces>
- <edge cases / error handling to address>

Step 2 — ...
...

## Testing plan
<how each step will be verified. New tests? Manual checks?>

## Rollout
<if applicable: feature flag? gradual rollout? migration strategy?>
```

Use the existing codebase as a guide — if there's an established pattern for similar features, mirror it. If the plan contradicts an existing pattern, call that out as a decision that needs discussion.

### 3. Present and wait

After writing the file, tell the user:

> PLAN.md written to `<absolute path>`.
> Please review the plan before I begin implementation.

Do not start implementing. The user must explicitly approve or request changes before any code is written.

## Relationship to other skills

- The plan is created **before** any code is written. If the user asks to implement something and no plan exists yet, pause and create one.
- After the plan is approved, the user will direct implementation — the **debug** and **review** skills may then apply to the implementation work.
- If the user says "just do it" or "no plan needed", respect that — this skill advises, it does not block.

## Anti-patterns

- Do not skip planning for tasks that involve >3 files or >50 lines of new code. Small fixes, typo corrections, and trivial refactors are fine without a plan.
- Do not write the plan and start implementing in the same response. The user must see and approve the plan first.
- Do not plan at a level that hides decisions — each step should be concrete enough that anyone reading the plan could verify the implementation against it.
