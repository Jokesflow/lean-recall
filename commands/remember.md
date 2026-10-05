---
description: Save a fact to project memory (no argument saves this session's durable facts)
argument-hint: [fact]
---

Update `.claude/memory/context.md` with: $ARGUMENTS

- No argument: save this session's confirmed durable facts instead (decisions and why, commands, conventions, preferences, task status).
- File missing: create it with a `# Project memory` title and the headings `## Stack`, `## Structure`, `## Commands`, `## Decisions`, `## Conventions & preferences`, `## Active tasks`.
- Read the file, then put each fact under its heading as one short line. Update or merge an existing entry instead of duplicating it; remove entries the new fact makes stale.
- Never store secrets, tokens, passwords, file contents or transient details: leave them out, save the rest, and say what you left out.
- Over ~150 lines afterwards: compress it the way `/mind-palace:compact-memory` does.
- If the write is denied or fails, say that nothing was saved.
- Reply with only the lines added, changed or removed.
