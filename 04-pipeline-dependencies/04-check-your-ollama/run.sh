#!/usr/bin/env bash
# Demo 4: check your own laptop. Read-only: starts nothing, changes nothing.
cd "$(dirname "$0")" && source ../../lib.sh

command -v ollama >/dev/null || { echo "Ollama is not installed. Show the backup slide."; exit 0; }
echo "OLLAMA_HOST = ${OLLAMA_HOST:-not set (default: 127.0.0.1)}"

if [ "$(uname)" = Darwin ]; then
  show "lsof -nP -iTCP:11434 -sTCP:LISTEN"
else
  show "ss -ltnp | grep 11434"
fi || echo "(nothing listening: Ollama is not running)"
pause

if command -v jq >/dev/null; then
  show "curl -s http://localhost:11434/api/tags | jq -r '.models[].name'"
else
  show "curl -s http://localhost:11434/api/tags | head"
fi || echo "(no answer: Ollama is not running)"
