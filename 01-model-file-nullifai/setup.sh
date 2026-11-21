#!/usr/bin/env bash
# Install torch and picklescan once, into .venv in this folder.
cd "$(dirname "$0")"
python3.12 -m venv .venv || python3 -m venv .venv
.venv/bin/pip install -q torch "numpy<2" picklescan==1.0.5
