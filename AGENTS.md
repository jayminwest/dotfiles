# AGENTS.md — dotfiles

One public repo configures every machine: Macs (nix-darwin + home-manager)
and Linux VMs (standalone home-manager). Same shell, editor, file manager,
herdr and toolchains everywhere; same Flick and AeroSpace bindings on every
desktop.

## Rule zero: this repo is public

Nothing that identifies a person, machine or network: no tailnet names
(`tail<hex>.ts.net`), Tailscale IPs, phone numbers, personal emails, machine
names, ssh users, `/Users/<name>` or `/home/<name>` paths. This applies to
files, commit messages and comments. Use placeholders (`server.example.ts.net`,
`100.64.0.x`, `my-laptop`, `me@server`, `$HOME`). Anything personal goes in the
private overlay (below). `./check.sh` enforces this in the commit hooks and CI.
Never weaken a pattern in it; add new ones to the private `deny.txt`.

## Commands

| Command | Does |
|---|---|
| `./bootstrap.sh --role desktop\|server\|vm [--host NAME]` | Fresh machine: writes `~/.config/dotfiles/machine.nix`, installs Nix, links `~/.dotfiles`, runs `rebuild.sh`. Safe to re-run. |
| `./rebuild.sh` | Build + activate this machine. After every change or `git pull`. |
| `./check.sh` | Public-safety scan + build every role. Must pass before pushing. |
| `./check.sh --fast` | Scan only (pre-commit hook). |
| `./brew-drift.sh` | macOS: brew packages installed but not declared. Read-only. |

The repo lives at `~/.dotfiles` on every machine. All config links resolve
through that path.

## Roles

A role is what a machine *is*. It is not a machine name.

| Role | OS | Modules |
|---|---|---|
| `desktop` | macOS | `darwin.nix` `darwin-desktop.nix` + home `core` `mac` `desktop` |
| `server` | macOS | `darwin.nix` + home `core` `mac` |
| `vm` | Linux | home `core` `linux` |

Defined in `flake.nix` (`roles`). `flake.nix` reads the machine from
`~/.config/dotfiles/machine.nix` (`{ role, host, user, home, system }`). Only
`bootstrap.sh` writes that file, and it is never committed. `rebuild.sh` passes
it in with `--override-input machine`. `stub/machine` is the CI example.

## Layout

```
flake.nix               roles, mkDarwin/mkHome, ci-* configs, packages
modules/darwin.nix      every Mac: macOS defaults, Homebrew base lists
modules/darwin-desktop.nix  desktop casks/brews, AeroSpace install
modules/home/core.nix   EVERY machine: packages, zsh, git, starship, links
modules/home/mac.nix    every Mac: infra/media tools, fonts, WezTerm, Flick
modules/home/desktop.nix    desktop: AeroSpace config
modules/home/linux.nix  vm: genericLinux
pkgs/                   herdr, AeroSpace (pinned release binaries)
home/                   real config files, linked edit-in-place into ~
agents/AGENTS.md        global agent instructions (~/.claude/CLAUDE.md etc.)
stub/                   default flake inputs (CI machine, empty overlay)
```

## Where a change goes

- **A CLI tool for every machine**: `modules/home/core.nix` `home.packages`.
  Use `mac.nix` only if it is macOS-only or GUI-related.
- **Config for an app** (nvim, yazi, herdr, wezterm, aerospace, flick): edit
  `home/.config/<app>/...`. These files are linked out-of-store, so edits apply
  without a rebuild. A new file needs a `home.file` link in the right module,
  then a rebuild.
- **A Homebrew formula/cask**: `darwin.nix` for every Mac,
  `darwin-desktop.nix` for desktops only. Prefer nixpkgs. Use brew only for
  launchd services, macOS-integrated tools, Metal builds and Swift tooling.
- **Keybindings** (Flick, AeroSpace) are always in the shared public files,
  so all desktops behave the same. Flick overlays hold endpoints only. An
  overlay that sets `[[keys.chord]]` replaces the whole shared list.
- **Anything personal** (services, machine names, endpoints, private
  scripts): the private overlay, never this repo.
- **A new role**: add it to `roles` in `flake.nix`, add a `ci-<role>` config,
  build it in `check.sh`, and add it to `bootstrap.sh`.
- **Bump herdr or AeroSpace**: edit the version in `pkgs/*.nix`. The file
  header gives the prefetch command for the new hash.

## Private overlay

`~/sync/dotfiles-local/` (Syncthing, not git). When it exists, `rebuild.sh`
passes it with `--override-input private`. `default.nix` takes `{ machine }`
and returns `{ darwin = [ ... ]; home = [ ... ]; }`, usually by choosing
`hosts/<host>.nix` from `machine.host`. Without the overlay, a machine gets
the public config only. That is the normal case for VMs and the work Mac.
`deny.txt` in it adds private patterns to `check.sh`.

Machine-local, never synced: `~/.zshrc.local` (secrets, env),
`~/.config/git/local` (`[user]` name/email/signingkey).

## Verify

- Run `./check.sh` before every push. On macOS it builds both darwin roles
  and evaluates the vm. CI (Linux) builds the vm and evaluates the darwin
  roles.
- Run `./rebuild.sh` to see a change on this machine.
- Out-of-store links mean a broken file in `home/` breaks the app, not the
  build. Open the app to check.

## Manual steps (cannot be automated)

- **Desktop:** grant AeroSpace Accessibility on first launch. Install Flick
  from github.com/jayminwest/flick (`scripts/bundle.sh --install`); its
  launchd agent exits cleanly until Flick is installed. Download the whisper
  model for dictation (see the comment in `home/.config/flick/config.toml`).
- **Any machine:** create `~/.config/git/local`, and run `gh auth login` and
  the logins for each agent harness.
