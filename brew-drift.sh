#!/usr/bin/env bash
# List brew formulae/casks/taps installed but missing from configuration.nix
# (via the Brewfile nix-darwin writes to /etc/Brewfile). Read-only.
set -uo pipefail
out="$(HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 \
  /opt/homebrew/bin/brew bundle cleanup --file=/etc/Brewfile 2>/dev/null \
  | sed -n '/^Would `brew cleanup`/q; /^Run `brew bundle cleanup/q; s/^Would uninstall //; s/^Would untap:/taps:/; p')"
[ -n "$out" ] && printf '\033[33mbrew-drift: installed but not in configuration.nix\033[0m\n%s\n' "$out"
exit 0
