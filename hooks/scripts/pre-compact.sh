#!/bin/sh
# lean-recall PreCompact hook, manual /compact only.
# PreCompact output never reaches Claude, so the reminder is a one-time block:
# if memory exists but was not updated since the context began (session start
# or last compaction), stop this /compact and tell the user. The next /compact
# proceeds. Auto-compaction is never blocked; session-start.sh covers it.
# Disable with LEAN_RECALL_COMPACT_GATE=0.

[ "${LEAN_RECALL_COMPACT_GATE:-1}" = 0 ] && exit 0
mem="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/memory/context.md"
[ -f "$mem" ] || exit 0

input=
[ -t 0 ] || input=$(cat)
sid=$(printf '%s\n' "$input" |
  sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
  head -n 1 | tr -cd 'A-Za-z0-9_-')

state="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/lean-recall-$(id -u)}/sessions"
mkdir -p "$state" 2>/dev/null || exit 0
mark="$state/${sid:-default}.mark"
warned="$state/${sid:-default}.warned"

if [ -f "$warned" ] || [ -n "$(find "$mem" -newer "$mark" 2>/dev/null)" ]; then
  rm -f "$warned"
  : > "$mark"
  exit 0
fi

: > "$warned"
echo "lean-recall: project memory has not been updated in this context. Run /lean-recall:remember to save durable facts, then /compact. Or run /compact again to compact anyway." >&2
exit 2
