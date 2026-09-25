#!/bin/bash

input=$(cat)
git_info=$(echo "$input" | bash ~/.claude/statusline-command.sh)

transcript=$(echo "$input" | sed -n 's/.*"transcript_path":"\([^"]*\)".*/\1/p')
model_id=$(echo "$input" | sed -n 's/.*"model":{[^}]*"id":"\([^"]*\)".*/\1/p')

case "$model_id" in
  *opus*|*sonnet*) max=1000000 ;;
  *haiku*|*)       max=200000  ;;
esac
[ -n "$CLAUDE_CTX_MAX" ] && max=$CLAUDE_CTX_MAX

context_str=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  used=$(jq -r 'select(.message.usage) | .message.usage | (.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0)' "$transcript" 2>/dev/null | tail -1)
  if [ -n "$used" ] && [ "$used" -gt 0 ] 2>/dev/null; then
    [ "$used" -gt "$max" ] && max=1000000
    pct=$(awk -v u="$used" -v m="$max" 'BEGIN { printf "%.0f", (u/m)*100 }')
    used_fmt=$(LC_ALL=en_US.UTF-8 /usr/bin/printf "%'d" "$used" 2>/dev/null) || used_fmt="$used"
    context_str=$(printf '\033[01;33m%s (%s%%)\033[00m' "$used_fmt" "$pct")
  fi
fi

if [ -n "$context_str" ]; then
  printf '%s | %s' "$git_info" "$context_str"
else
  printf '%s' "$git_info"
fi
