{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
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
    lazygit
    neovim
    gh
    just
    gnupg
    # languages
    go
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
    "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept

      export GPG_TTY=$(tty)

      # bun completions
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

      # tools that may not be installed everywhere
      command -v entire >/dev/null 2>&1 && source <(entire completion zsh)
      command -v but >/dev/null 2>&1 && eval "$(but completions zsh)"

      # machine-local secrets and overrides - never committed to this repo
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
    shellAliases = {
      ".." = "cd ..";
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
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real files live in this repo, ~/.config just points at
  # them. Editing home/.config/* takes effect immediately - no rebuild needed.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
}
