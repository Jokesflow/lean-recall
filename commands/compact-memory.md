---
description: Compress and prune project memory to stay under ~150 lines
---

Compact `.claude/memory/context.md`. If it is missing, say so and stop.

1. Read it.
2. Check entries that may be stale against the repo with Grep/Glob and targeted reads: commands, paths, versions, open tasks.
3. Keep an entry unless it is verified stale, duplicated, transient or secret. Never drop an active task or a decision still in force.
4. Merge duplicates, shorten each entry to one line, keep the template headings.
5. Target well under 150 lines. Write the file once; if the write is denied or fails, say the file is unchanged.
6. Reply with `<before> → <after> lines` and a one-line summary of what was removed.
