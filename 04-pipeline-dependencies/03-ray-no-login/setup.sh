#!/usr/bin/env bash
# Install Ray once, into .venv in this folder.
# Intel Macs can only get Ray 2.49.2. Everyone else gets 2.60.0.
cd "$(dirname "$0")"
VERSION=2.60.0
[ "$(uname -sm)" = "Darwin x86_64" ] && VERSION=2.49.2
python3.12 -m venv .venv || python3 -m venv .venv
.venv/bin/pip install -q "ray[default]==$VERSION"
.venv/bin/ray --version
