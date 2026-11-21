# Two helpers used by every run.sh.

# show "command" ["filtered command"]
# Prints "$ command" in color, then runs it.
# If a second command is given, that one runs instead (same thing, less log spam).
show() {
  printf '\n\e[1;36m$ %s\e[0m\n' "$1"
  eval "${2:-$1}"
}

# Wait for Enter, so you can talk.
pause() {
  read -rp $'\n[press Enter] '
}
