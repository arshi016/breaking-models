#!/usr/bin/env bash
# Stop anything left running (Ray) and reset the demos.
cd "$(dirname "$0")"
03-ray-no-login/.venv/bin/ray stop --force >/dev/null 2>&1 && echo "Ray stopped."
../01-model-file-nullifai/reset.sh
