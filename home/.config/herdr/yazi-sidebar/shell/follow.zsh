# Sourced by zsh (home.nix): on every `cd` inside herdr, move this tab's yazi
# sidebar (if open) to the new directory. bin/sidebar writes the registry.
_herdr_yazi_follow() {
  [[ -n $HERDR_TAB_ID ]] || return 0
  local reg=${XDG_STATE_HOME:-$HOME/.local/state}/herdr/plugins/yazi-sidebar/${HERDR_TAB_ID//:/_}
  [[ -r $reg ]] && { ya emit-to "$(<$reg)" cd "$PWD" &>/dev/null &! }
  return 0
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _herdr_yazi_follow
