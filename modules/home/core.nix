# Every machine, every role: shell, editor, file manager, herdr, toolchains,
# agent instructions. Keep this OS-neutral; macOS-only bits go in mac.nix.
{ config, lib, pkgs, machine, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Edit-in-place symlink into this repo (no rebuild needed after edits).
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
  # Same, into a repo under ~/Projects (dangles where that repo isn't cloned).
  project = name: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Projects/${name}";
in

{
  home.username = machine.user;
  home.homeDirectory = machine.home;
  home.stateVersion = "25.05";

  # CLI tools. Add a line + ./rebuild.sh to install; delete a line to remove.
  home.packages = with pkgs; [
    # daily terminal
    herdr  # pkgs/herdr.nix
    ripgrep
    fd
    fzf
    jq
    yazi
    lazygit
    neovim
    gh
    just
    gnupg
    eza
    bat
    tree
    wget
    btop
    # language servers (nvim)
    (lib.hiPrio rust-analyzer)  # wins over rustup's rust-analyzer proxy
    typescript-language-server
    marksman
    gopls
    # languages
    go
    golangci-lint
    gofumpt
    nodejs
    bun
    rustup  # toolchains live in ~/.rustup (default pinned there)
    uv
    ruff
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    BUN_INSTALL = "${config.home.homeDirectory}/.bun";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
    "$HOME/.bun/bin"
    "$HOME/go/bin"
    "$HOME/.deno/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    defaultKeymap = "viins";           # vi editing: Esc for normal mode, i to insert
    initContent = ''
      bindkey '^f' autosuggest-accept

      # vi-mode quality of life
      KEYTIMEOUT=1                              # near-instant Esc into normal mode
      bindkey -v '^?' backward-delete-char      # backspace works past the insert point

      # word jumping: ctrl+arrows (CSI 1;5) and alt+arrows (CSI 1;3)
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;3C' forward-word
      bindkey '^[[1;3D' backward-word

      export GPG_TTY=$(tty)

      # bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # tools that may not be installed everywhere
      command -v entire >/dev/null 2>&1 && source <(entire completion zsh)
      command -v but >/dev/null 2>&1 && eval "$(but completions zsh)"

      # herdr: keep this tab's yazi sidebar in step with `cd`
      [ -r "$HOME/.dotfiles/home/.config/herdr/yazi-sidebar/shell/follow.zsh" ] && \
        source "$HOME/.dotfiles/home/.config/herdr/yazi-sidebar/shell/follow.zsh"

      # machine-local secrets and overrides - never committed to this repo
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

      # terminal theme (dark=Kanagawa / light=Everforest). Ensure the shared
      # mode file + yazi theme symlink exist and agree (self-heals after a
      # home-manager rebuild that removes ~/.config/yazi).
      [ -f "$HOME/.config/theme-mode" ] || printf 'dark\n' > "$HOME/.config/theme-mode"
      _tm="$(tr -d '[:space:]' < "$HOME/.config/theme-mode" 2>/dev/null || echo dark)"
      mkdir -p "$HOME/.config/yazi"
      ln -sfn "$HOME/.dotfiles/home/.config/yazi/theme-''${_tm}.toml" "$HOME/.config/yazi/theme.toml" 2>/dev/null || true
      unset _tm
    '';
    shellAliases = {
      ".." = "cd ..";
      theme = "$HOME/.dotfiles/home/.config/theme/toggle";
      ls = "eza";
      ll = "eza -la --git";
      tree = "eza --tree";
    };
  };

  programs.zoxide.enable = true; # `z <dir>` jumps by frecency
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
        vimcmd_symbol = "[❮](green)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Identity is machine-local (~/.config/git/local: [user] name/email/signingkey)
  # so no identity lands in this public repo. Signing is on in mac.nix only.
  programs.git = {
    enable = true;
    ignores = [ "**/.claude/settings.local.json" "**/.claude/.cc-writes/" ];
    signing.format = "ssh";
    settings = {
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      credential."https://github.com".helper = "!gh auth git-credential";
      credential."https://gist.github.com".helper = "!gh auth git-credential";
    };
    includes = [ { path = "~/.config/git/local"; } ];
  };

  # Edit-in-place: the real files live in this repo, ~/.config just points at
  # them. Editing home/.config/* takes effect immediately - no rebuild needed.
  home.file.".config/nvim".source = link "home/.config/nvim";
  # File, not dir: ~/.config/herdr also holds sockets, logs, session + plugin state.
  home.file.".config/herdr/config.toml".source = link "home/.config/herdr/config.toml";
  # yazi: per-file, not the dir - the `theme` toggle owns ~/.config/yazi/theme.toml
  # as a symlink it repoints between this repo's dark/light templates.
  home.file.".config/yazi/yazi.toml".source = link "home/.config/yazi/yazi.toml";
  # herdr plugins register via the CLI, not files; link the local yazi sidebar
  # (edits apply live) if missing. Never fail the switch.
  home.activation.herdrPlugins = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    herdr=${pkgs.herdr}/bin/herdr
    if ! "$herdr" plugin list 2>/dev/null | grep -q yazi-sidebar; then
      run "$herdr" plugin link "${dotfiles}/home/.config/herdr/yazi-sidebar" || true
    fi
  '';

  # Agents: one AGENTS.md for all. Per-file links only - these dirs also hold
  # auth, history, and sqlite state that must never be committed.
  # force: hosts (e.g. cloud VMs) may preinstall these as symlinks, which
  # home-manager never backs up; this repo owns them, so replace the link.
  home.file.".claude/CLAUDE.md" = { source = link "agents/AGENTS.md"; force = true; };
  home.file.".codex/AGENTS.md" = { source = link "agents/AGENTS.md"; force = true; };
  home.file.".pi/agent/AGENTS.md" = { source = link "agents/AGENTS.md"; force = true; };
  home.file.".claude/statusline-command.sh".source = link "home/.claude/statusline-command.sh";
  home.file.".claude/statusline-wrapper.sh".source = link "home/.claude/statusline-wrapper.sh";
  home.file.".pi/agent/agents".source = link "home/.pi/agent/agents";
  home.file.".pi/agent/models.json".source = link "home/.pi/agent/models.json";
  # Skills that live in their own repos. Per-skill links: ~/.claude/skills also
  # holds app-managed dirs (synced/).
  home.file.".claude/skills/scaffold-project".source = project "scaffold-project";
  home.file.".agents/skills/scaffold-project".source = project "scaffold-project";
  home.file.".pi/agent/skills/scaffold-project".source = project "scaffold-project";
}
