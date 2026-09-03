#!/usr/bin/env bash
# Self-check for deny-secret-reads.sh. Run it after any edit to the pattern lists.
# Kept as a file rather than a one-liner because the payloads name secret paths, and the
# hook denies any Bash command that does.
set -uo pipefail

H="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/deny-secret-reads.sh"
fail=0

run() {
  local out
  out=$(printf '%s' "$1" | bash "$H")
  if [ -z "$out" ]; then echo allow; else jq -r '.hookSpecificOutput.permissionDecision' <<<"$out"; fi
}

check() {
  local want="$1" payload="$2" got subject
  got=$(run "$payload")
  subject=$(jq -r '.tool_input.file_path // .tool_input.command' <<<"$payload")
  if [ "$got" != "$want" ]; then
    fail=1
    printf '%-6s %-6s ** %s\n' "$want" "$got" "$subject"
  else
    printf '%-6s %-6s %s\n' "$want" "$got" "$subject"
  fi
}

r() { printf '{"tool_name":"Read","tool_input":{"file_path":%s}}' "$(jq -Rn --arg v "$1" '$v')"; }
b() { printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$(jq -Rn --arg v "$1" '$v')"; }

printf '%-6s %-6s %s\n' EXPECT GOT SUBJECT

echo "-- Read: credential stores --"
check deny "$(r '/Users/b/.kube/config')"
check deny "$(r '/Users/b/.aws/config')"
check deny "$(r '/Users/b/.aws/credentials')"
check deny "$(r '/Users/b/.azure/accessTokens.json')"
check deny "$(r '/Users/b/.config/gh/hosts.yml')"
check deny "$(r '/Users/b/.docker/config.json')"
check deny "$(r '/Users/b/.gnupg/secring.gpg')"
check deny "$(r '/Users/b/.npmrc')"
check deny "$(r '/Users/b/.npm/_cacache/index')"
check deny "$(r '/Users/b/.git-credentials')"
check deny "$(r '/Users/b/.pypirc')"
check deny "$(r '/Users/b/.gem/credentials')"
check deny "$(r '/Users/b/.netrc')"
check deny "$(r '/Users/b/Library/Keychains/login.keychain-db')"
check deny "$(r '/Users/b/Library/Application Support/metamask-x/vault')"
check deny "$(r '/Users/b/.ssh/config')"
check deny "$(r '/repo/helix/.env')"
check deny "$(r '/repo/tls/server.key')"
check deny "$(r '/repo/tls/server.pem')"

echo "-- Read: must stay allowed --"
check allow "$(r '/repo/internal/oras/commands.go')"
check allow "$(r '/repo/.env.example')"
check allow "$(r '/repo/.env.sample')"
check allow "$(r '/repo/deployment/kustomization.yaml')"
check allow "$(r '/repo/docs/operations/metrics.md')"

echo "-- Bash: narrow set only --"
check deny "$(b 'cat ~/.ssh/id_ed25519')"
check deny "$(b 'cat /tmp/id_rsa')"
check deny "$(b 'grep -o "GRAFANA[A-Z_]*" .env')"
check deny "$(b 'cat .env.example && cat .env')"
check deny "$(b 'cp .env.template .env.local')"
check deny "$(b 'openssl x509 -in server.pem -noout')"

echo "-- Bash: must stay allowed --"
check allow "$(b 'kubectl --context shared-services get pods')"
check allow "$(b 'KUBECONFIG=/Users/b/.kube/config kubectl get pods')"
check allow "$(b 'gh pr view 875 --json body')"
check allow "$(b 'grep -rn "func Init" --include="*.go" . | grep -v _test')"
check allow "$(b 'cat .env.sample')"
check allow "$(b 'make generate && go build ./...')"

echo
if [ "$fail" -eq 0 ]; then
  echo "ALL PASS"
else
  echo "FAILURES MARKED **"
  exit 1
fi
