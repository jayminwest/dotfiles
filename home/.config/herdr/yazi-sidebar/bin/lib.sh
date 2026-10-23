# Shared helpers, sourced by the bin/ scripts.

SIDEBAR_LABEL=yazi-sidebar
SIDEBAR_WIDTH=${HERDR_YAZI_WIDTH:-32}  # columns
STATE_DIR=${HERDR_PLUGIN_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/herdr/plugins/yazi-sidebar}

# Raw socket call for methods the CLI lacks (pane.focus, layout.set_split_ratio).
api() {
  printf '{"id":"yazi-sidebar","method":"%s","params":%s}\n' "$1" "$2" |
    nc -U "${HERDR_SOCKET_PATH:-$HOME/.config/herdr/herdr.sock}"
}

# Set the right-split that exactly covers rect $2 (JSON) in pane $1's tab so
# its first child is $SIDEBAR_WIDTH columns. Split ids encode their path from
# the tab root: split_<n>_root = [], split_<n>_01 = [first, second].
size_first_child() {
  local pane=$1 rect=$2 split
  split=$(herdr pane layout --pane "$pane" | jq -c --argjson r "$rect" '
    [.result.layout.splits[] | select(.direction == "right" and .rect == $r)]
    | max_by(.id | length) // empty')
  [[ -n $split ]] || return 0
  api layout.set_split_ratio "$(jq -c --arg p "$pane" --argjson w "$SIDEBAR_WIDTH" '{
    pane_id: $p,
    path: (.id | split("_")[2] | if . == "root" then [] else split("") | map(. == "1") end),
    ratio: ([[$w / .rect.width, 0.1] | max, 0.9] | min)
  }' <<<"$split")" >/dev/null
}
