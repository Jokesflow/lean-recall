---
description: Save a fact to project memory (no argument saves this session's durable facts)
argument-hint: [fact]
---

Update `.claude/memory/context.md` with: $ARGUMENTS

- No argument: save this session's confirmed durable facts instead (decisions and why, commands, conventions, preferences, task status).
- File missing: create it from `${CLAUDE_PLUGIN_ROOT}/templates/context.md`.
- Read the file, then put each fact under its heading as one short line. Update or merge an existing entry instead of duplicating it; remove entries the new fact makes stale.
- Never store secrets, tokens, passwords, file contents or transient details. Refuse them and say why.
- Over ~150 lines afterwards: compress it the way `/lean-recall:compact-memory` does.
- Reply with only the lines added, changed or removed.
