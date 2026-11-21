#!/usr/bin/env bash
# Install zizmor once. Tries pipx, then a local .venv, then brew.
cd "$(dirname "$0")"
pipx install zizmor 2>/dev/null ||
  { python3 -m venv .venv && .venv/bin/pip install -q zizmor; } ||
  brew install zizmor
