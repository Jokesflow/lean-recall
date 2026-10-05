# Privacy Policy: mind-palace

_Last updated: 2026-10-05_

mind-palace is a Claude Code plugin that runs entirely on your machine. Its publisher (Jokesflow) operates no server and receives no data from the plugin.

## What the plugin handles

- **Your project memory file**, `.claude/memory/context.md` in your project. It holds durable project facts: stack, structure, commands, decisions, conventions, preferences and open tasks. Claude Code creates and edits it only when you ask or approve. In its default permission modes, Claude Code asks before every write to `.claude/`.
- **Session marker files.** These are empty files named after the Claude Code session ID, stored in the plugin's data directory under `~/.claude/plugins/data/`. They only decide whether to remind you to save memory before a manual `/compact`. They are deleted automatically after 7 days.
- **Hook input.** The hooks read only the `session_id` and `source` fields that Claude Code passes to them. Neither field is stored, except as the marker file name above.

## What it does not do

- It makes no network requests and has no telemetry, analytics or tracking.
- It does not read credentials, secrets or environment variables, other than its own settings and the paths Claude Code provides.
- It reads no project file other than the memory file.
- Claude is instructed never to save secrets, tokens, passwords or personal data (names, emails, addresses, phone numbers) to memory.
- Symlinked and unreadable memory files are never loaded.

## Where your data goes

At the start of each session, the memory file's text is added to Claude's context. That means it is sent to Anthropic together with the rest of your Claude Code conversation, under your agreement with Anthropic (see [Anthropic's Privacy Policy](https://www.anthropic.com/legal/privacy)). The plugin sends nothing to anyone else.

## Retention and deletion

- **The publisher** keeps no data.
- **The memory file** stays in your project until you delete it with `rm .claude/memory/context.md`. If you commit it to git, anyone with access to the repository can read it.
- **Marker files** expire after 7 days. By default, uninstalling the plugin removes its data directory.

## Children

mind-palace is a developer tool and is not intended for users under 18.

## Contact

For questions about this policy, open an issue at <https://github.com/Jokesflow/mind-palace/issues>.
