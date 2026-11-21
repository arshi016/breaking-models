#!/usr/bin/env bash
# Optional: the fix. Same request, but now Ray asks for a token.
# Needs Ray 2.52 or newer. The token goes in this folder, not your home dir.
cd "$(dirname "$0")" && source ../../lib.sh
export PATH="$PWD/.venv/bin:$PATH"
export RAY_AUTH_TOKEN_PATH="$PWD/.tmp-token"
ray get-auth-token --help >/dev/null 2>&1 || { echo "fix.sh needs Ray 2.52 or newer. You have: $(ray --version)"; exit 1; }
ray stop >/dev/null 2>&1

show "ray get-auth-token --generate" "ray get-auth-token --generate >/dev/null && echo 'saved to .tmp-token'"
show "RAY_AUTH_MODE=token ray start --head --dashboard-host 127.0.0.1 --disable-usage-stats" \
     "RAY_AUTH_MODE=token ray start --head --dashboard-host 127.0.0.1 --node-ip-address 127.0.0.1 --disable-usage-stats 2>&1 | grep -E 'Token|Ray runtime started' | sed 's/.* -- //'"
pause

echo "# No token:"
show "env -u RAY_AUTH_TOKEN_PATH ray job submit --address http://127.0.0.1:8265 -- whoami" \
     "env -u RAY_AUTH_TOKEN_PATH ray job submit --address http://127.0.0.1:8265 -- whoami 2>&1 | tail -2"
pause

echo "# With the token:"
show "RAY_AUTH_MODE=token ray job submit --address http://127.0.0.1:8265 -- whoami" \
     "RAY_AUTH_MODE=token ray job submit --address http://127.0.0.1:8265 -- whoami 2>&1 | grep -E 'succeeded|failed|^[a-z]' | sed 's/.* -- //'"
