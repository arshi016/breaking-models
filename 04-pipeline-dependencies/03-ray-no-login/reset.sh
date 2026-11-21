#!/usr/bin/env bash
# Stop Ray and delete the temp token from fix.sh.
cd "$(dirname "$0")"
.venv/bin/ray stop --force >/dev/null 2>&1
rm -f .tmp-token
echo "Demo 3: Ray stopped."
