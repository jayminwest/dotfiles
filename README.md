# dotfiles

One Nix flake for every machine: Macs (nix-darwin + home-manager) and Linux
VMs (home-manager). Same zsh, nvim, yazi, herdr and toolchains everywhere.
On desktops, the same AeroSpace and Flick bindings.

```sh
# new machine
git clone https://github.com/jayminwest/dotfiles ~/.dotfiles
~/.dotfiles/bootstrap.sh --role desktop   # or: server (headless Mac), vm (Linux)

# after a change or pull
cd ~/.dotfiles && git pull && ./rebuild.sh
```

Personal settings stay out of this repo. They live in an optional private
overlay; see [AGENTS.md](AGENTS.md).
