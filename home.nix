{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Edit-in-place symlink into this repo (no rebuild needed after edits).
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfiles}/${path}";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "25.05";

  # CLI tools. Add a line + ./rebuild.sh to install; delete a line to remove.
  home.packages = with pkgs; [
    # daily terminal
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
    # languages
    go
    nodejs
    rustlings
    # infra
    flyctl
    kubectl
    kubernetes-helm
    k3d
    # media
    ffmpeg
    # font
    nerd-fonts.blex-mono
  ];
  fonts.fontconfig.enable = true;

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
    "$HOME/.brv-cli/bin"
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];

  programs.zsh = {
    enable = true;
    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv zsh)"
    '';
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
    };
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
  # so no identity lands in this public repo.
  programs.git = {
    enable = true;
    ignores = [ "**/.claude/settings.local.json" "**/.claude/.cc-writes/" ];
    signing = {
      format = "ssh";
      signByDefault = true;
    };
    settings = {
      gpg.ssh.allowedSignersFile = "~/.ssh/allowed_signers";
      credential."https://github.com".helper = "!gh auth git-credential";
      credential."https://gist.github.com".helper = "!gh auth git-credential";
    };
    includes = [ { path = "~/.config/git/local"; } ];
  };

  # Edit-in-place: the real files live in this repo, ~/.config just points at
  # them. Editing home/.config/* takes effect immediately - no rebuild needed.
  home.file.".config/wezterm".source = link "home/.config/wezterm";
  home.file.".config/nvim".source = link "home/.config/nvim";
  # File, not dir: ~/.config/herdr also holds sockets, logs, session + plugin state.
  home.file.".config/herdr/config.toml".source = link "home/.config/herdr/config.toml";

  # Agents: one AGENTS.md for all. Per-file links only - these dirs also hold
  # auth, history, and sqlite state that must never be committed.
  home.file.".claude/CLAUDE.md".source = link "agents/AGENTS.md";
  home.file.".codex/AGENTS.md".source = link "agents/AGENTS.md";
  home.file.".pi/agent/AGENTS.md".source = link "agents/AGENTS.md";
  home.file.".claude/statusline-command.sh".source = link "home/.claude/statusline-command.sh";
  home.file.".claude/statusline-wrapper.sh".source = link "home/.claude/statusline-wrapper.sh";
  home.file.".pi/agent/agents".source = link "home/.pi/agent/agents";
  home.file.".pi/agent/models.json".source = link "home/.pi/agent/models.json";
  # NB: ~/.config/yazi is intentionally NOT managed here. The `theme` toggle
  # owns ~/.config/yazi/theme.toml as a symlink into this repo's dark/light
  # templates, which home-manager (read-only store) could not repoint.
}
