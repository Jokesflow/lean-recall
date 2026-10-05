#!/bin/sh
# lean-recall SessionStart hook. Runs on startup, resume, clear and compact.
# Plain stdout is added to Claude's context; nothing else is printed.

input=
[ -t 0 ] || input=$(cat)

field() {
  printf '%s\n' "$input" |
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
}

root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
mem="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/memory/context.md"

# Baseline for pre-compact.sh: memory edits after this mark count as saved.
state="${CLAUDE_PLUGIN_DATA:-${TMPDIR:-/tmp}/lean-recall-$(id -u)}/sessions"
sid=$(field session_id | tr -cd 'A-Za-z0-9_-')
if mkdir -p "$state" 2>/dev/null; then
  find "$state" -type f -mtime +7 -exec rm -f {} + 2>/dev/null
  rm -f "$state/${sid:-default}.warned"
  : > "$state/${sid:-default}.mark"
fi

if [ ! -f "$mem" ]; then
  echo "lean-recall: no project memory yet. To start one, create .claude/memory/context.md from $root/templates/context.md, or run /lean-recall:remember <fact>."
  exit 0
fi

lines=$(wc -l < "$mem" | tr -d ' ')
bytes=$(wc -c < "$mem" | tr -d ' ')

# Notes go before the body: hook output over 10,000 chars reaches Claude only as a 2,000-char preview.
echo "# Project memory (.claude/memory/context.md, $lines lines). Keep it current per the lean-recall skill."
if [ "$lines" -gt 150 ] || [ "$bytes" -gt 9000 ]; then
  echo "Memory is over budget (~150 lines / 9 KB): run /lean-recall:compact-memory."
fi
if [ "$(field source)" = compact ]; then
  echo "Context was just compacted: save durable facts from the summary that are missing below, then continue."
fi
echo
cat "$mem"
