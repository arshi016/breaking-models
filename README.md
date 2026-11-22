# Breaking Models: AI supply-chain security labs

Live demos from my talk **"Breaking Models"**. Localhost only, harmless payloads (`echo PWNED`, `whoami`, a fake key).

| Lab | What you see |
|---|---|
| [`01-nullifai`](01-nullifai/) | Loading a model file runs a command. A broken pickle still runs it (nullifAI) |
| [`02-paste-vs-variable`](02-paste-vs-variable/) | `${{ }}` vs `env:` in GitHub Actions (Ultralytics) |
| [`03-zizmor-scan`](03-zizmor-scan/) | zizmor finds both Ultralytics bugs |
| [`04-ray-no-login`](04-ray-no-login/) | Ray runs any command, no password (ShadowRay) |
| [`05-check-your-ollama`](05-check-your-ollama/) | Is your Ollama open to the network? |
| [`06-one-line-diff`](06-one-line-diff/) | postmark-mcp: the whole attack is one line |
| [`07-tool-poisoning`](07-tool-poisoning/) | "Adds two numbers" + a hidden `<IMPORTANT>` block |

Each lab's `README.md` has the commands to type.

## Install (once, inside each lab folder)
```
01-nullifai:                 python3.12 -m venv .venv && .venv/bin/pip install torch "numpy<2" picklescan==1.0.5
03-zizmor-scan:              python3 -m venv .venv && .venv/bin/pip install zizmor
04-ray-no-login:             python3.12 -m venv .venv && .venv/bin/pip install "ray[default]==2.60.0"
07-tool-poisoning:           python3.12 -m venv .venv && .venv/bin/pip install mcp
```
Intel Mac: use `ray[default]==2.49.2`. Tool poisoning needs Claude Code. Ollama lab needs Ollama running.
