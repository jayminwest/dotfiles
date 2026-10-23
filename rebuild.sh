#!/usr/bin/env bash
# Builds and activates this machine's config. Run after every change or pull.
# Usage: ./rebuild.sh   (role/user/host come from ~/.config/dotfiles/machine.nix,
#                        written by ./bootstrap.sh)
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

machine="$HOME/.config/dotfiles"
private="$HOME/sync/dotfiles-local"
[ -r "$machine/machine.nix" ] || { echo "rebuild: no $machine/machine.nix; run ./bootstrap.sh --role ..." >&2; exit 1; }

# The commit hooks run ./check.sh --fast (public-safety scan).
git -C "$DIR" config core.hooksPath .githooks
# Commits here are public: author as the GitHub noreply address.
git -C "$DIR" config user.email 28354219+jayminwest@users.noreply.github.com

args=(--override-input machine "path:$machine")
[ -r "$private/default.nix" ] && args+=(--override-input private "path:$private")

# sudo resets PATH, so resolve nix first.
nix="$(command -v nix)"
case "$(uname -s)" in
  Darwin)
    # The flake's pinned darwin-rebuild: works on a fresh Mac too.
    sudo "$nix" run "$DIR#darwin-rebuild" -- switch --flake "$DIR#default" "${args[@]}"
    "$DIR/brew-drift.sh"
    ;;
  Linux)
    out="$("$nix" build --no-link --print-out-paths "$DIR#homeConfigurations.default.activationPackage" "${args[@]}")"
    "$out/activate"
    ;;
esac
