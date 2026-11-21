#!/usr/bin/env bash
# Demo: a model file that runs a command when you load it (pickle + nullifAI).
# Payload is harmless: echo PWNED.
cd "$(dirname "$0")" && source ../lib.sh
export PATH="$PWD/.venv/bin:$PATH"

show "cat make_model.py"
show "python make_model.py"
pause

show "python load_unsafe.py"
pause

show "python load_safe.py" \
     "python load_safe.py 2>&1 | grep -oE 'Weights only load failed|[Uu]nsupported (class|GLOBAL) [a-z.]+'"
pause

echo "# nullifAI: break the file. The payload still runs first."
show "python make_broken.py"
show "python -m pickletools evil.pkl" \
     "python -u -m pickletools evil.pkl 2>&1 | grep -E 'GLOBAL|UNICODE|REDUCE|^ValueError'"
show "python -c \"import pickle; pickle.load(open('evil.pkl', 'rb'))\"" \
     "python -c \"import pickle; pickle.load(open('evil.pkl', 'rb'))\" 2>&1 | grep -E 'PWNED|Error'"
pause

show "picklescan --path model.pt" "picklescan --path model.pt 2>&1 | grep -E 'FOUND|Infected' | sed \"s|$PWD/||\""
show "picklescan --path evil.pkl" "picklescan --path evil.pkl 2>&1 | grep -E 'FOUND|Infected' | sed \"s|$PWD/||\""
