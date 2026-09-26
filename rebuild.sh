#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
ln -sfn "$DIR" ~/.dotfiles
sudo darwin-rebuild switch --flake ~/.dotfiles#"$(whoami)"
"$DIR/brew-drift.sh"
