#!/usr/bin/env bash
# The one gate. This repo is public: nothing that identifies a person, a
# machine, or a network may land in it.
#   ./check.sh          scan + build every role (CI, before a push)
#   ./check.sh --fast   scan only (pre-commit hook)
#   ./check.sh --msg F  scan commit message file F (commit-msg hook)
# Extra private patterns (machine names, usernames, ...), one ERE per line:
# ~/sync/dotfiles-local/deny.txt. Patterns only ever get added.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$DIR"

patterns="$(mktemp)"; trap 'rm -f "$patterns"' EXIT
cat > "$patterns" <<'EOF'
tail[0-9a-f]{4,}\.ts\.net
\b100\.(6[4-9]|[7-9][0-9]|1[01][0-9]|12[0-7])\.[0-9]{1,3}\.[0-9]{1,3}\b
\+[1-9][0-9]{9,14}\b
[A-Za-z0-9._%+-]+@(gmail|googlemail|icloud|me|mac|fastmail|proton|protonmail|pm|outlook|hotmail|live|yahoo)\.(com|me|net)
(^|[^A-Za-z0-9._-])/(Users|home)/[a-z][a-z0-9._-]*
EOF
deny="$HOME/sync/dotfiles-local/deny.txt"
[ -r "$deny" ] && grep -vE '^\s*(#|$)' "$deny" >> "$patterns"

fail() { printf '\033[31mcheck: %s\033[0m\n' "$*" >&2; exit 1; }

if [ "${1:-}" = --msg ]; then
  hits="$(grep -vE '^#' "$2" | grep -niE -f "$patterns" || true)"
  [ -z "$hits" ] || fail "personal data in the commit message:"$'\n'"$hits"
  exit 0
fi

# Commit identity is public too (use the GitHub noreply address; rebuild.sh sets it).
ident="$(git var GIT_AUTHOR_IDENT 2>/dev/null || true)"
if printf '%s\n' "$ident" | grep -qiE -f "$patterns"; then fail "personal email in the commit author: $ident"; fi

# Index content: what the next commit would publish.
hits="$(git grep --cached -nIiE -f "$patterns" || true)"
[ -z "$hits" ] || fail "personal data in tracked files (use placeholders; see AGENTS.md):"$'\n'"$hits"
[ "${1:-}" = --fast ] && exit 0

echo "check: building every role"
case "$(uname -s)" in
  Darwin)
    nix build --no-link .#darwinConfigurations.ci-desktop.system .#darwinConfigurations.ci-server.system
    nix eval --raw .#homeConfigurations.ci-vm.activationPackage.drvPath >/dev/null
    ;;
  Linux)
    nix build --no-link .#homeConfigurations.ci-vm.activationPackage
    for r in desktop server; do
      nix eval --raw ".#darwinConfigurations.ci-$r.system.drvPath" >/dev/null
    done
    ;;
esac
echo "check: ok"
