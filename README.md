# lean-recall

A Claude Code plugin that cuts token waste without cutting corners, and gives every project a small persistent memory. Claude locates code before reading it, reads only the ranges it needs, trims command output and answers concisely, but reads more whenever correctness requires it. Durable project facts (stack, commands, decisions, conventions, open tasks) live in `.claude/memory/context.md`, and hooks load that file into every session automatically. You don't have to re-explain the project after a restart, `/clear` or compaction.

## Installation

```
/plugin marketplace add Jokesflow/lean-recall
/plugin install lean-recall@lean-recall
```

Then start a new session. The memory hook runs at session start.

## Commands

| Command | What it does |
| --- | --- |
| `/lean-recall:remember <fact>` | Saves a fact under the right heading, merging it with existing entries instead of duplicating them. With no argument, it saves the durable facts from the current session. |
| `/lean-recall:recall` | Shows the current memory file and its line count. |
| `/lean-recall:compact-memory` | Checks entries against the repo, then merges, compresses and prunes stale ones to stay under ~150 lines. |

Plugin commands are namespaced, so type the full `/lean-recall:` name.

The `lean-recall` skill holds the working rules: correctness first, then token efficiency and memory upkeep. Claude loads it when relevant, and the session-start header points Claude to it before memory edits. To load it explicitly, run `/lean-recall:lean-recall`.

## Hooks

| Event | What it does |
| --- | --- |
| `SessionStart` (startup, resume, `/clear`, fork, after compaction) | Injects `.claude/memory/context.md` into Claude's context. If the file is over budget, it asks for `/lean-recall:compact-memory`. After a compaction, it tells Claude to save any durable facts from the summary that are missing from memory. If the file doesn't exist, it adds a one-line note pointing to the template. A symlinked memory file is never loaded. |
| `PreCompact` (manual `/compact` only) | If memory exists but hasn't changed since the session started or since the last compaction, it blocks that one `/compact` and asks you to run `/lean-recall:remember` first. Running `/compact` again proceeds, including from a resumed `-p` session. |

Claude Code discards PreCompact output, so a one-time block is the only way to act before compaction. Automatic compaction is never blocked. The SessionStart hook handles that case right after compaction. To turn the block off, set `LEAN_RECALL_COMPACT_GATE=0`, for example under `"env"` in `.claude/settings.json`. In `-p` scripts, run `/compact` twice or set the variable.

The hooks are dependency-free POSIX `sh` and print nothing except the output described above. Their only state is two empty marker files per session in the plugin's data directory, and those are pruned after 7 days. On Windows, the hooks need [Git for Windows](https://gitforwindows.org/), whose `sh` runs them.

## How memory works

- **Location:** `.claude/memory/context.md` in the project root (the directory you start Claude Code in). It's plain Markdown, and you can edit it by hand.
- **Permissions:** `.claude/` is a protected path, so Claude Code asks before each write to this file. Where it can't ask (`-p` in default or `acceptEdits` mode, or `dontAsk`), the write is denied. Allow rules can't pre-approve it. To stop repeat prompts, choose *Yes, and allow Claude to edit files in this project's .claude folder for this session*.
- **What goes in:** stack, project structure, build/test/run commands, key decisions with reasons, conventions, user preferences, active tasks and remaining work.
- **What never goes in:** transient details, file contents, secrets, tokens, passwords.
- **Budget:** about 150 lines. Entries get merged, compressed and pruned instead of appended forever. Hook output over 10,000 characters reaches Claude only as a preview, so the hook warns past 150 lines or 9 KB.
- **Updates:** Claude updates memory briefly after significant tasks. You can also save facts with `/lean-recall:remember`.
- **Sharing:** commit the file to share it with your team, or add `.claude/memory/` to `.gitignore` to keep it personal. If you commit it, review its diffs: it loads into every session like `CLAUDE.md`, and a leaked secret stays in git history (remove it and rotate the secret).

### Reset

```sh
rm .claude/memory/context.md
```

The next session notes that no memory exists. The next `/lean-recall:remember` recreates the file with the template's headings.

## License

[MIT](LICENSE)
