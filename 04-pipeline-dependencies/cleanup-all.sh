#!/usr/bin/env bash
# Stop anything left running (Ray) and reset every demo.
cd "$(dirname "$0")"
for d in 0*/; do [ -x "$d/reset.sh" ] && "$d/reset.sh"; done
