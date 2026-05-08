#!/usr/bin/env bash
# Bypass ExitWorktree tool (claude-code#36205: tool skips WorktreeRemove hook).
# Run wt directly, deny the tool, instruct Claude to cd back via Bash.
set -euo pipefail
event=$(cat)
action=$(jq -r '.tool_input.action // "keep"' <<<"${event}")
discard=$(jq -r '.tool_input.discard_changes // false' <<<"${event}")

main_path=$(wt list --format=json 2>/dev/null | jq -r '.[] | select(.is_main) | .path' 2>/dev/null || echo "")
current_path=$(wt list --format=json 2>/dev/null | jq -r '.[] | select(.is_current) | .path' 2>/dev/null || echo "")

reason="ExitWorktree disabled. Use Bash: wt switch - (keep) or wt remove <path> (remove)."

if [[ -n "${current_path}" && -n "${main_path}" && "${current_path}" != "${main_path}" ]]; then
  if [[ "${action}" == "remove" ]]; then
    flags=()
    [[ "${discard}" == "true" ]] && flags+=(-D)
    if ( cd "${main_path}" && wt remove "${flags[@]}" "${current_path}" ) >/dev/null 2>&1; then
      reason="Worktree removed. cd via Bash to ${main_path}."
    else
      reason="wt remove failed at ${current_path}. Investigate via Bash. Do not retry ExitWorktree."
    fi
  else
    reason="Keeping worktree at ${current_path}. cd via Bash to ${main_path} to leave it."
  fi
fi

jq -n --arg r "${reason}" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: $r
  }
}'
