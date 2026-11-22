# Breaking Models: AI supply-chain security labs

Live demos from my talk **"Breaking Models"**. Localhost only, harmless payloads (`echo PWNED`, `whoami`, a fake key).

| Lab | What you see |
|---|---|
| [`01-model-file-nullifai`](01-model-file-nullifai/) | Loading a model file runs a command. A broken pickle still runs it (nullifAI) |
| [`04-pipeline-dependencies/01-paste-vs-variable`](04-pipeline-dependencies/01-paste-vs-variable/) | `${{ }}` vs `env:` in GitHub Actions (Ultralytics) |
| [`04-pipeline-dependencies/02-zizmor-scan`](04-pipeline-dependencies/02-zizmor-scan/) | zizmor finds both Ultralytics bugs |
| [`04-pipeline-dependencies/03-ray-no-login`](04-pipeline-dependencies/03-ray-no-login/) | Ray runs any command, no password (ShadowRay) |
| [`04-pipeline-dependencies/04-check-your-ollama`](04-pipeline-dependencies/04-check-your-ollama/) | Is your Ollama open to the network? |
| [`05-agentic-runtime/01-one-line-diff`](05-agentic-runtime/01-one-line-diff/) | postmark-mcp: the whole attack is one line |
| [`05-agentic-runtime/02-tool-poisoning`](05-agentic-runtime/02-tool-poisoning/) | "Adds two numbers" + a hidden `<IMPORTANT>` block |

Each lab's `README.md` has the commands to type.

## Install (once, inside each lab folder)
```
01-model-file-nullifai:     python3.12 -m venv .venv && .venv/bin/pip install torch "numpy<2" picklescan==1.0.5
02-zizmor-scan:             python3 -m venv .venv && .venv/bin/pip install zizmor
03-ray-no-login:            python3.12 -m venv .venv && .venv/bin/pip install "ray[default]==2.60.0"
02-tool-poisoning:          python3.12 -m venv .venv && .venv/bin/pip install mcp
```
Intel Mac: use `ray[default]==2.49.2`. Tool poisoning needs Claude Code. Ollama lab needs Ollama running.
