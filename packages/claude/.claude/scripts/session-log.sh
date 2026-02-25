#!/bin/bash
# Session Logger - Writes Claude Code session summaries to Obsidian vault
# Usage: Called by hooks or manually with session JSON via stdin

VAULT_PATH="${OBSIDIAN_VAULT:-'Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal'}"
DAILY_DIR="$VAULT_PATH/Daily_Claude"
TODAY=$(date +%Y-%m-%d)
DAILY_FILE="$DAILY_DIR/$TODAY.md"
TIMESTAMP=$(date +%H:%M)
SESSION_ID=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || echo "$$-$RANDOM")

# Verify vault directory exists
if [ ! -d "$VAULT_PATH" ]; then
    echo "Warning: Vault directory not found at $VAULT_PATH" >&2
    exit 0
fi

# Parse session data from stdin
input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "unknown"')
DIR_NAME="${DIR##*/}"
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
DURATION_MIN=$((DURATION_MS / 60000))

# Skip zero-value ghost sessions: no duration, no changes, no known directory
# These fire on hook init/test calls with empty payloads and produce noise.
COST_INT=$(printf "%.0f" "$(echo "$COST * 1000" | awk '{printf "%f", $1}')" 2>/dev/null || echo 0)
if [ "$DURATION_MIN" -eq 0 ] && \
   [ "${COST_INT:-0}" = "0" ] && \
   [ "$LINES_ADDED" = "0" ] && \
   [ "$LINES_REMOVED" = "0" ] && \
   [ "$DIR_NAME" = "unknown" ]; then
    echo "Skipped zero-value ghost session" >&2
    exit 0
fi

# Ensure daily directory exists
mkdir -p "$DAILY_DIR"

# Use lock file to prevent concurrent write corruption
# LOCK_FILE="$DAILY_DIR/.session-log.lock"
# exec 9>"$LOCK_FILE"
# flock -w 5 9 || { echo "Warning: Could not acquire lock" >&2; exit 0; }

# Create daily file with template if it doesn't exist
if [ ! -f "$DAILY_FILE" ]; then
    cat > "$DAILY_FILE" << EOF
---
title: "Claude Daily Log: $TODAY"
type: daily-log
created: $TODAY
tags: [#log/daily, #namespace/logs]
---

# $TODAY

## Strategic Focus

What is the primary focus for today aligned with MRAX philosophy?

## Captured

### Inbox Items
-

### Quick Notes
-

## Actions Taken

- [ ]
- [ ]

## Learnings

What did I learn today? What patterns emerged?

## Links Created

- [[]] -
- [[]] -

---

## Session Logs

EOF
fi

# If the file exists but has no Session Logs section, add it
if ! grep -q "^## Session Logs" "$DAILY_FILE"; then
    printf '\n---\n\n## Session Logs\n\n' >> "$DAILY_FILE"
fi

# Append session entry
cat >> "$DAILY_FILE" << EOF

### $TIMESTAMP - $DIR_NAME
- **Session**: ${SESSION_ID:0:8}
- **Model**: $MODEL
- **Duration**: ${DURATION_MIN}m
- **Changes**: +$LINES_ADDED / -$LINES_REMOVED lines
- **Cost**: \$$(printf "%.3f" "$COST")

EOF

# Release lock
# exec 9>&-

echo "Logged to $DAILY_FILE"
