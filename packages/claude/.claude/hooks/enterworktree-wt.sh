#!/usr/bin/env bash
# Bypass EnterWorktree tool (claude-code#36205: tool skips WorktreeCreate hook).
# Run wt directly, deny the tool, return path so Claude can cd via Bash.
set -euo pipefail
event=$(cat)
name=$(jq -r '.tool_input.name // empty' <<<"${event}")
existing=$(jq -r '.tool_input.path // empty' <<<"${event}")

reason="EnterWorktree disabled. Use Bash: wt switch --create <name>"

if [[ -n "${existing}" ]]; then
  reason="Worktree already on disk at ${existing}. cd via Bash. Do not retry EnterWorktree."
elif [[ -n "${name}" ]]; then
  if path=$(wt switch --create "${name}" --no-cd --format=json 2>/dev/null | jq -r '.path' 2>/dev/null); then
    if [[ -n "${path}" && "${path}" != "null" ]]; then
      reason="Worktree created at ${path}. cd via Bash to work in it. Do not retry EnterWorktree."
    fi
  fi
fi

jq -n --arg r "${reason}" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $r
  }
}'
