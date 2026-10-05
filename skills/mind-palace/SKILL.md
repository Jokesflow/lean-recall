---
name: mind-palace
description: Persistent project memory in .claude/memory/context.md plus lean, correctness-first working rules. Use when saving, recalling or updating durable project facts (decisions, conventions, commands, open tasks), and before multi-step coding work in a repository.
---

# mind-palace

## Correctness first
These override every rule below.
- If a correct answer needs more reading, read more.
- Give architecture, debugging and refactoring full depth.
- Inspect the actual code before changing it. Never guess.
- Treat memory as a lead, not proof: verify it against the code before acting on it.

## Token efficiency
- Locate before reading: Grep/Glob first, then Read only the relevant ranges (`offset`/`limit`).
- Never re-read a file that is in context and unchanged.
- Trim command output: `head`, `tail`, `--quiet`, `grep`. Never dump full logs.
- Run independent tool calls in parallel.
- Reply concisely: no restating the task, no preamble, no recap of what you just did.

## Project memory
File: `.claude/memory/context.md`. A hook injects it at session start; Read it only to edit it.
- Store only durable, high-value facts:
  - stack, project structure, build/test/run commands
  - key decisions and the reason for each
  - code conventions and user preferences
  - active tasks and remaining work
- Never store transient details, file contents, secrets, tokens or passwords.
- One short line per entry, under the template's headings.
- Stay under ~150 lines: merge, compress and prune stale entries instead of appending.
- After a significant task, update it briefly: edit the affected lines, don't append a log.
- File missing: don't create it unprompted; suggest `/mind-palace:remember`.
