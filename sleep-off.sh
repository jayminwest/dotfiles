#!/usr/bin/env bash
# Keep the Mac awake, lid closed too, until this exits (Ctrl-C or the
# terminal closes); then restore normal sleep. kill -9 skips the restore:
# run it again and Ctrl-C.
[ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"
pmset -a disablesleep 1
trap 'pmset -a disablesleep 0' EXIT
trap 'exit' HUP INT TERM
caffeinate -w $$ &
wait
