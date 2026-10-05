#!/bin/sh
# mind-palace SessionStart hook. Runs on startup, resume, clear, compact and fork.
# Plain stdout is added to Claude's context; nothing else is printed.

input=
[ -t 0 ] || input=$(cat)

field() {
  printf '%s\n' "$input" |
    sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -n 1
}

root=${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/../.." && pwd)}
mem="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/memory/context.md"
src=$(field source)

# Baseline for pre-compact.sh: memory edits after this mark count as saved.
# A resume keeps the existing baseline, so a /compact retried in a new process passes.
if [ -n "$CLAUDE_PLUGIN_DATA" ]; then
  state="$CLAUDE_PLUGIN_DATA/sessions"
  sid=$(field session_id | tr -cd 'A-Za-z0-9_-')
  mark="$state/${sid:-default}.mark"
  if mkdir -p "$state" 2>/dev/null; then
    find "$state" -type f -mtime +6 -exec rm -f {} + 2>/dev/null
    if [ "$src" != resume ] || [ ! -f "$mark" ]; then
      rm -f "$state/${sid:-default}.warned" 2>/dev/null
      touch "$mark" 2>/dev/null
    fi
  fi
fi

# A symlink could point anywhere (e.g. a key file), so it is never loaded.
if [ -L "$mem" ]; then
  echo "mind-palace: .claude/memory/context.md is a symlink, so it was not loaded."
  exit 0
fi

if [ ! -f "$mem" ]; then
  printf '%s\n' "mind-palace: no project memory yet. Start one with /mind-palace:remember <fact>, or copy $root/templates/context.md to .claude/memory/context.md."
  if [ "$src" = compact ]; then
    echo "Context was just compacted: if the summary has durable project facts, save them with /mind-palace:remember."
  fi
  exit 0
fi

if [ ! -r "$mem" ]; then
  echo "mind-palace: .claude/memory/context.md is not readable, so it was not loaded."
  exit 0
fi

lines=$(wc -l < "$mem" | tr -d ' ')
bytes=$(wc -c < "$mem" | tr -d ' ')

# Notes go before the body: hook output over 10,000 chars reaches Claude only as a 2,000-char preview.
echo "# Project memory (.claude/memory/context.md, $lines lines). Before editing it, load the mind-palace:mind-palace skill."
if [ "$lines" -gt 150 ] || [ "$bytes" -gt 9000 ]; then
  echo "Memory is over budget (~150 lines / 9 KB): run /mind-palace:compact-memory."
fi
if [ "$src" = compact ]; then
  echo "Context was just compacted: save durable facts from the summary that are missing below, then continue."
fi
echo
cat "$mem"
