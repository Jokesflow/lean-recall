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

Plugin commands are namespaced. The short form (`/remember`) also works while no other command uses that name.

The `lean-recall` skill holds the working rules: correctness first, then token efficiency and memory upkeep. Claude loads it for coding tasks, and you can invoke it with `/lean-recall:lean-recall`.

## Hooks

| Event | What it does |
| --- | --- |
| `SessionStart` (startup, resume, `/clear`, after compaction) | Injects `.claude/memory/context.md` into Claude's context. If the file is over budget, it asks for `/lean-recall:compact-memory`. After a compaction, it tells Claude to save any durable facts from the summary that are missing from memory. If the file doesn't exist, it adds a one-line note pointing to the template. |
| `PreCompact` (manual `/compact` only) | If memory exists but hasn't changed since the session started or since the last compaction, it blocks that one `/compact` and asks you to run `/lean-recall:remember` first. Running `/compact` again proceeds. |

Claude Code discards PreCompact output, so a one-time block is the only way to act before compaction. Automatic compaction is never blocked. The SessionStart hook handles that case right after compaction. To turn the block off, set `LEAN_RECALL_COMPACT_GATE=0`, for example under `"env"` in `.claude/settings.json`.

The hooks are dependency-free POSIX `sh` and print nothing except the output described above. Their only state is two empty marker files per session in the plugin's data directory, and those are pruned after 7 days.

## How memory works

- **Location:** `.claude/memory/context.md` in the project root. It's plain Markdown, and you can edit it by hand.
- **What goes in:** stack, project structure, build/test/run commands, key decisions with reasons, conventions, user preferences, active tasks and remaining work.
- **What never goes in:** transient details, file contents, secrets, tokens, passwords.
- **Budget:** about 150 lines. Entries get merged, compressed and pruned instead of appended forever. Hook output over 10,000 characters reaches Claude only as a preview, so the hook warns past 150 lines or 9 KB.
- **Updates:** Claude updates memory briefly after significant tasks. You can also save facts with `/lean-recall:remember`.
- **Sharing:** commit the file to share it with your team, or add `.claude/memory/` to `.gitignore` to keep it personal.

### Reset

```sh
rm .claude/memory/context.md
```

The next session notes that no memory exists. The next `/lean-recall:remember` recreates the file from the template.

## License

[MIT](LICENSE)
