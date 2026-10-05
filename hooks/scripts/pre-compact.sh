#!/bin/sh
# lean-recall PreCompact hook, manual /compact only.
# PreCompact output never reaches Claude, so the reminder is a one-time block:
# if memory exists but was not updated since the context began (session start
# or last compaction), stop this /compact and tell the user. The next /compact
# proceeds. Auto-compaction is never blocked; session-start.sh covers it.
# Disable with LEAN_RECALL_COMPACT_GATE=0.

[ "${LEAN_RECALL_COMPACT_GATE:-1}" = 0 ] && exit 0
[ -n "$CLAUDE_PLUGIN_DATA" ] || exit 0
mem="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/memory/context.md"
if [ ! -f "$mem" ] || [ -L "$mem" ] || [ ! -r "$mem" ]; then exit 0; fi

input=
[ -t 0 ] || input=$(cat)
sid=$(printf '%s\n' "$input" |
  sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
  head -n 1 | tr -cd 'A-Za-z0-9_-')

state="$CLAUDE_PLUGIN_DATA/sessions"
mark="$state/${sid:-default}.mark"
warned="$state/${sid:-default}.warned"

# Saved since the baseline, or already warned once: let it run.
# SessionStart(compact) resets the state once compaction is done.
if [ -f "$warned" ] || [ -n "$(find "$mem" -newer "$mark" 2>/dev/null)" ]; then
  exit 0
fi

# Never block unless the warning can be recorded, or every /compact would stay blocked.
mkdir -p "$state" 2>/dev/null
touch "$warned" 2>/dev/null || exit 0
echo "lean-recall: .claude/memory/context.md is unchanged since this session started or was last compacted. Save facts with /lean-recall:remember, then /compact. Running /compact again skips this check; LEAN_RECALL_COMPACT_GATE=0 turns it off." >&2
exit 2
