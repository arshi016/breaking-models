#!/usr/bin/env bash
# Run the morning of the talk. Checks tools and ports. Changes nothing.
cd "$(dirname "$0")"

check() { if eval "$2" >/dev/null 2>&1; then echo "  PASS  $1"; else echo "  FAIL  $1"; fi; }
free()  { ! { lsof -nP -iTCP:"$1" -sTCP:LISTEN || ss -ltn "sport = :$1" | grep -q LISTEN; }; }

echo "Demo 1"
check "bash" "command -v bash"
echo "Demo 2"
check "zizmor installed (else see 02-zizmor-scan/README.md)" "command -v zizmor || [ -x 02-zizmor-scan/.venv/bin/zizmor ]"
echo "Demo 3"
check "ray installed (else run 03-ray-no-login/setup.sh)" "[ -x 03-ray-no-login/.venv/bin/ray ]"
for p in 6379 8265 10001; do check "port $p free" "free $p"; done
check "no ~/.ray/auth_token (else: RAY_AUTH_MODE=disabled ./run.sh)" "[ ! -f ~/.ray/auth_token ]"
check "RAY_AUTH_TOKEN not set (else: RAY_AUTH_MODE=disabled ./run.sh)" "[ -z \"$RAY_AUTH_TOKEN\" ]"
echo "Demo 4"
check "curl" "command -v curl"
check "lsof or ss" "command -v lsof || command -v ss"
check "jq (optional)" "command -v jq"
check "ollama installed (else use backup slide)" "command -v ollama"
check "ollama running (else open the app)" "! free 11434"
check "ollama NOT open to the network (*:11434)" "! lsof -nP -iTCP:11434 -sTCP:LISTEN | grep -q '\*:11434'"
echo "  INFO  OLLAMA_HOST = ${OLLAMA_HOST:-not set}"
