#=============================================================================
# OmniRoute
#=============================================================================

# The gateway runs as a Docker container holding the SQLite database open, so
# stop it rather than killing it: the container carries --stop-timeout 40 and
# `docker stop` honours it, giving SQLite time to close cleanly.
alias orup='docker start omniroute'
alias ordown='docker stop omniroute'
alias orlog='docker logs -f --tail 50 omniroute'

# `--restart unless-stopped` means ordown also keeps it down across a reboot
# until orup runs. That is the intent, not a bug.

# Claude Code routed through the gateway to Kiro models.
# Plain `claude` is untouched and still reaches Anthropic.
#
# This needs no omniroute binary: no npm global to break when node changes, and
# no OmniRoute process reading a dotenv file out of the current directory.
#
# Token lives in the keychain, put there by `omniroute contexts migrate`.
# kr/auto lets Kiro pick, but returns nothing under `claude -p`, so pass an
# explicit model for headless runs: kclaude --model kr/claude-sonnet-5 -p '...'
kclaude() {
  ANTHROPIC_BASE_URL="http://localhost:20128" \
  ANTHROPIC_AUTH_TOKEN="$(security find-generic-password -s omniroute-cli -a 'omniroute-cli:context:local' -w)" \
  CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1 \
  command claude --model kr/auto "$@"
}
