#!/usr/bin/env bash
# Demo 2: zizmor finds both Ultralytics bugs. Local files only, nothing is pushed.
cd "$(dirname "$0")" && source ../../lib.sh
export PATH="$PWD/.venv/bin:$PATH"

show "cat vulnerable-repo/.github/workflows/format.yml"
pause

show "zizmor --offline vulnerable-repo" \
     "zizmor --offline vulnerable-repo 2>&1 | grep -E '^error|-->|findings'"
pause

show "cat fixed-repo/.github/workflows/format.yml"
pause

show "zizmor --offline fixed-repo" \
     "zizmor --offline fixed-repo 2>&1 | grep -E '^error|-->|findings'"
