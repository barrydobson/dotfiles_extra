#!/usr/bin/env bash
# PreToolUse guard for Read and Bash. Replaces the Read() deny rules that used to live in
# permissions.deny. Those rules armed a static-resolution permission gate: with any Read()
# deny rule configured, Claude Code cannot prove that a recursive grep will avoid the denied
# path, so it forces an approval prompt that no allow rule and no bypass mode can clear.
# That gate stalled unattended runs for as long as nobody was at the keyboard.
#
# Two matchers, deliberately asymmetric:
#   Read - the tool gives an explicit file_path, so match it broadly. No false positives.
#   Bash - only a command string is available, so keep the set narrow. A broad match here
#          hard-blocks legitimate commands that merely mention a path.
#
# ponytail: literal match on the command string for Bash. A recursive grep that happens to
# walk a secret file is not caught, because the path never appears in the command. That is
# the deliberate trade, since demanding static proof is what armed the gate. Upgrade path if
# incidental reads start to matter: a PostToolUse redaction hook on tool output.
set -euo pipefail

payload=$(cat)

tool=$(jq -r '.tool_name // ""' <<<"$payload")

case "$tool" in
Read) subject=$(jq -r '.tool_input.file_path // ""' <<<"$payload") ;;
Bash) subject=$(jq -r '.tool_input.command // ""' <<<"$payload") ;;
*) exit 0 ;;
esac

[ -n "$subject" ] || exit 0

# Sample and template env files carry no secrets and are routinely needed. Remove them from
# the subject rather than exempting the whole call, so a command naming both a template and
# a real secret is still denied.
scrubbed=$(printf '%s' "$subject" | sed -E 's/\.env\.(example|sample|template|dist)//g')

# bash [[ =~ ]] is POSIX ERE, which has no \b. Use explicit non-word neighbours.
edge='([^[:alnum:]_]|$)'

# Shapes recognisable inside a shell command without guessing. Applied to Read and Bash.
common="\\.env(\\.|${edge})|/\\.ssh/|(^|[^[:alnum:]_])id_(rsa|ed25519|ecdsa)${edge}|\\.(pem|p12|pfx|key)${edge}|/\\.aws/credentials|/\\.netrc"

# Credential stores named by path. Applied to Read only, where the path is explicit.
paths="/\\.aws/|/\\.azure/|/\\.config/gh/|/\\.docker/config\\.json|/\\.gnupg/|/\\.kube/|/\\.npm/|/\\.npmrc${edge}|/\\.pypirc${edge}|/\\.gem/credentials|/\\.git-credentials|/Library/Keychains/|/Library/Application Support/[^/]*(metamask|phantom|exodus|solflare|electrum)"

if [ "$tool" = "Read" ]; then
  pattern="${common}|${paths}"
else
  pattern="$common"
fi

if [[ $scrubbed =~ $pattern ]]; then
  jq -nc \
    --arg reason "Blocked by deny-secret-reads.sh: the $tool call names a credential or key file. Ask the user for the specific value instead of reading the file." \
    '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
fi

exit 0
