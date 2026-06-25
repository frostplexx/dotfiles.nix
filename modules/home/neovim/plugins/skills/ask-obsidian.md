---
description: Search the ~/Documents/Memex Obsidian vault and answer questions grounded in its notes. Read-only — never writes, moves, or deletes anything in the vault.
---

Search the Obsidian vault at `~/Documents/Memex` and answer the user's question using only what is actually written there.

## Rules

- **Read-only.** Never create, edit, move, or delete any file in the vault.
- **Ground every answer.** Read the source material first, then answer. No answers from memory alone.
- **Cite explicitly.** For each claim, name the note it came from (e.g. `[[Note Title]]` or `Memex/folder/note.md`).
- **If the vault has nothing**, say so — do not invent or fill gaps with general knowledge unless explicitly asked.

## Source hierarchy (most reliable first)

1. Lecture slides and PDFs referenced in notes
2. The internet (only to fill gaps the vault doesn't cover)
3. Exercise sheets
4. The user's own prose notes (may contain mistakes)

## Workflow

1. **Parse the question** — identify the key concepts, topic, or filename to search for.
2. **Search broadly** — use ripgrep to find every note that mentions the topic.
3. **Read the hits** — open and read the full content of the most relevant files.
4. **Chase references** — if a note links to another (`[[...]]`) or embeds a PDF, follow it.
5. **Extract PDF text if needed** — use `pdftotext` for slide decks and lecture PDFs.
6. **Answer with citations** — write a grounded answer that names every source.

## Search commands

```bash
# Find notes mentioning a term (list files)
rg -l "term" ~/Documents/Memex

# Find notes with context lines
rg -C 3 "term" ~/Documents/Memex --glob "*.md"

# Case-insensitive, word-boundary match
rg -i -w "term" ~/Documents/Memex --glob "*.md"

# Search inside a specific subfolder
rg "term" ~/Documents/Memex/Lectures --glob "*.md"

# List all notes in a folder
ls ~/Documents/Memex/SomeFolder/

# Extract text from a PDF (plain or layout-preserving)
pdftotext ~/Documents/Memex/path/to/file.pdf -
pdftotext -layout ~/Documents/Memex/path/to/file.pdf -

# Extract only specific pages
pdftotext -f 3 -l 8 ~/Documents/Memex/path/to/file.pdf -

# Read a note
cat ~/Documents/Memex/path/to/note.md
```

## Correlating with the current codebase

If the question is about something in the open editor or working directory, first grep the vault for the relevant concept, then cross-reference what the notes say with what the code actually does. Never modify either the vault or the code as part of this skill.
