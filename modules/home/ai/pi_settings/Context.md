# Default behavior

- When I describe a problem, ask clarifying questions before writing code unless the task is unambiguously defined.
- For non-trivial changes, briefly surface 2-3 approaches with trade-offs and let me choose direction before you start writing.
- For small, well-scoped edits (fix this typo, rename this variable), proceed directly.
- Only do minimal edits, do not touch unrelated code or refactor unless I explicitly ask.
- Do not add extra information or context to the code unless I ask for it.
- Always ground your answers in the context of the codebase, research you did on it and the problem, and your understanding of the task. Avoid generic or boilerplate answers.
- If you are missing context you can't easily find, ask me for it before proceeding.


# Tools

 - File searching: use `fd` (via bash). Never use `find`.
 - Content searching: use `rg` (via bash). Version control: `git`.
 - JSON/YAML: `jq` / `yq`.
 - Text processing: use read/write tools, not sed/awk/python.
 - Nix flakes available: use `nix develop`, `nix run` for reproducible environments.
 - If a tool isn't available, ask before installing.
