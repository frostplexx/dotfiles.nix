# Working in this vault

This is my Obsidian vault, a **PKM / second brain**. It holds university lecture notes, but also technical notes,
project ideas, references, and general life stuff. Treat it as a thinking and study tool, not a codebase.

## Writing style

- **Match the surrounding notes.** Open the neighbouring files first and copy their tone, structure, and formatting.
- Keep it **short, legible, and not AI-sounding**. No filler, no padding, no "in conclusion".
- **Never use em-dashes.** Use a comma, a full stop, or a colon instead.
- Prefer **bullet points** over paragraphs. **Bold** the key terms.
- Use Obsidian syntax: wikilinks `[[Note]]`, embeds `![[file.pdf#page=6]]`, callouts `> [!NOTE]`, LaTeX `$...$`.
- **Link heavily and inline.** Weave links into the prose and bullets, never collect them into a "Related Notes" section. Link notes (`[[Note]]`), headers (`[[Note#Section]]`), and text blocks (`[[Note^blockid]]`) wherever the concept appears naturally. Examples:
  - `This is the concolic counterpart of [[#Solution 3: Search Heuristics|search heuristics]] in symbolic execution.`
  - `If one representative of an EC fails, all others will too → [[Mengen und Abbildungen#Vollständige Induktion|induction]]`
  - `evaluated automatically, e.g., assertions. → [[02 Testen#Assertions]]`

## Tools

- **Always use the Obsidian skills**, especially the **Obsidian CLI** (`obsidian-cli`), to read, search, create, and edit notes. Do not bypass it with raw file commands when a skill command fits.
- Use `obsidian-markdown`, `obsidian-bases`, and `json-canvas` skills for their respective file types.

## Editing rules

- **Do not delete large chunks of text** or **change the meaning** of a note without asking first.
- Small fixes (typos, formatting, adding a line) are fine. Anything that rewrites or removes existing content needs a quick check with me.
- When unsure, ask before changing.

## Grounding

**Always ground your answers and knowledge in a real source.** Do not invent facts. Read the source, then write.

When I **ask a question**, the answer must be grounded and **properly sourced**: read the relevant material first, then cite where it came from (link the note, embed the slide, name the page). No answers from memory alone.

Source hierarchy, most reliable first:

1. **Lecture Notes** (slides, lecture PDFs)
2. **The Internet**
3. **Exercise Sheets**
4. **My own notes**

Read the lecture slides and PDFs before reaching for anything else. Use the internet to fill gaps. Treat my own notes as the least authoritative, they may contain mistakes.

### Reading PDFs

Use `pdftotext` to pull text out of slide and lecture PDFs:

```bash
pdftotext input.pdf output.txt              # plain text
pdftotext -layout input.pdf output.txt      # preserve layout
pdftotext -f 1 -l 5 input.pdf output.txt    # only pages 1-5
```
