#!/usr/bin/env bash
# Takes a fresh machine from nothing to a built config. Safe to re-run.
# After it finishes, use ./rebuild.sh for every later change.
#
# Usage: ./bootstrap.sh --role desktop|server|vm [--host NAME]
#   desktop  macOS, a Mac you sit at (AeroSpace, Flick, GUI apps)
#   server   macOS, headless/always-on
#   vm       Linux (Ubuntu + Nix), CLI only
#   --host   picks this machine's modules in the private overlay
#            (~/sync/dotfiles-local); defaults to the role
set -euo pipefail

# Never as root: ~ would be /root and the config would land on the wrong user.
# The scripts call sudo themselves where needed.
[ "$(id -u)" != 0 ] || { echo "$(basename "$0"): run as your user, not root/sudo" >&2; exit 1; }
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
die() { echo "bootstrap: $*" >&2; exit 1; }
usage() { sed -n '2,11s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"; }

role= host=
while [ $# -gt 0 ]; do
  case "$1" in
    --role) role="${2:-}"; shift 2 ;;
    --host) host="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
[ -n "$role" ] || { usage >&2; exit 2; }

case "$(uname -s)/$role" in
  Darwin/desktop|Darwin/server) os=darwin ;;
  Linux/vm) os=linux ;;
  *) die "role '$role' does not run on $(uname -s)" ;;
esac
case "$(uname -m)" in
  arm64|aarch64) arch=aarch64 ;;
  x86_64) arch=x86_64 ;;
  *) die "unsupported CPU $(uname -m)" ;;
esac

echo "==> Machine identity: ~/.config/dotfiles/machine.nix (never committed)"
mkdir -p "$HOME/.config/dotfiles"
cat > "$HOME/.config/dotfiles/machine.nix" <<EOF
{
  role = "$role";
  host = "${host:-$role}";
  user = "$(id -un)";
  home = "$HOME";
  system = "$arch-$os";
}
EOF

echo "==> Nix (Determinate)"
if command -v nix >/dev/null 2>&1; then
  echo "    already installed"
else
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

echo "==> This repo at ~/.dotfiles"
# Every config link resolves through ~/.dotfiles. Clone straight there; a
# clone elsewhere gets a symlink (an existing real directory is left alone).
if [ "$DIR" != "$(cd "$HOME/.dotfiles" 2>/dev/null && pwd -P)" ]; then
  [ -e "$HOME/.dotfiles" ] && [ ! -L "$HOME/.dotfiles" ] && die "~/.dotfiles exists and is not this repo"
  ln -sfn "$DIR" "$HOME/.dotfiles"
fi

if [ "$os" = linux ] && [ "$(basename "${SHELL:-}")" != zsh ]; then
  echo "==> zsh as login shell"
  command -v zsh >/dev/null 2>&1 || { sudo apt-get update -q && sudo apt-get install -yq zsh; }
  sudo chsh -s "$(command -v zsh)" "$(id -un)"
fi

exec "$DIR/rebuild.sh"
