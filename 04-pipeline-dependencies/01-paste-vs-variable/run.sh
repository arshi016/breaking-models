#!/usr/bin/env bash
# Demo 1: why ${{ github.head_ref }} in a run: line is code injection.
# eval = GitHub pasting the branch name into the script.
cd "$(dirname "$0")" && source ../../lib.sh

echo "# An attacker names their branch:"
show "BRANCH='\$(echo PWNED)'"
pause

echo "# Pasted into the script, like \${{ github.head_ref }}:"
show 'eval "echo Building $BRANCH"'
pause

echo "# Passed as a variable, like env: BRANCH:"
show 'echo "Building $BRANCH"'
pause

echo "# Bonus: it runs as YOU."
show "BRANCH='\$(whoami)'"
show 'eval "echo Building $BRANCH"'
