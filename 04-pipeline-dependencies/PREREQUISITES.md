# Prerequisites (install once)

```
cd 02-zizmor-scan  && python3 -m venv .venv && .venv/bin/pip install zizmor
cd ../03-ray-no-login && python3.12 -m venv .venv && .venv/bin/pip install "ray[default]==2.60.0"
```
- Intel Mac: Ray `2.60.0` is not available. Use `2.49.2`.
- If you have `~/.ray/auth_token`, Ray 2.52+ refuses the demo job. Start Ray with `RAY_AUTH_MODE=disabled` in front.
- Then check everything: `./00-preflight.sh`
- Demo 4: open the Ollama app first. `jq` is optional (without it, drop the `| jq ...` part).
