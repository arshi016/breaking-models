# #4 Pipeline & dependencies

Four short demos. Localhost only, harmless payloads.

```
./00-preflight.sh     # the morning of the talk: PASS / FAIL per demo
./cleanup-all.sh      # stop everything (Ray) and reset every demo
```
Expected output for every demo, as text for backup slides: [`BACKUP.md`](BACKUP.md).

---

## Demo 1: paste vs variable
```
$ BRANCH='$(echo PWNED)'
$ bash -c "echo Building $BRANCH"
Building PWNED
$ echo "Building $BRANCH"
Building $(echo PWNED)
```

---

## Demo 2: zizmor scan
Typed by hand. Steps: [`02-zizmor-scan/README.md`](02-zizmor-scan/README.md)
```
$ zizmor --offline vulnerable-repo
error[dangerous-triggers]: use of fundamentally insecure workflow trigger
 --> vulnerable-repo/.github/workflows/format.yml:2:1
error[template-injection]: code injection via template expansion
 --> vulnerable-repo/.github/workflows/format.yml:9:33
6 findings (4 suppressed, 1 unsafe fixes): 0 informational, 0 low, 0 medium, 2 high

$ zizmor --offline fixed-repo
No findings to report. Good job! (2 suppressed)
```
The fixed version uses `on: pull_request`, `permissions: {}`, and `env: BRANCH`. The "2 suppressed" are style tips that zizmor hides by default (no job `name:`, no `concurrency:`). They are not security bugs.

---

## Demo 3: Ray with no login (ShadowRay, CVE-2023-48022)
Typed by hand. Steps: [`03-ray-no-login/README.md`](03-ray-no-login/README.md)
```
$ ray start --head --node-ip-address 127.0.0.1 --dashboard-host 127.0.0.1 --disable-usage-stats
...
Ray runtime started.
...
$ ray job submit --address http://127.0.0.1:8265 -- whoami
...
warmearthling
Job 'raysubmit_kaekQjMsCR5huLU7' succeeded
```
On Ray 2.59+ `ray start` also prints a WARNING that token authentication is disabled.

---

## Demo 4: check your own Ollama
```
cd 04-check-your-ollama && ./run.sh
```
```
OLLAMA_HOST = not set (default: 127.0.0.1)
$ lsof -nP -iTCP:11434 -sTCP:LISTEN
ollama  34365 you  4u  IPv4 ...  TCP 127.0.0.1:11434 (LISTEN)
$ curl -s http://localhost:11434/api/tags | jq -r '.models[].name'
llama3.1:8b
```
Linux: `ss -ltnp | grep 11434`. The commands for the audience are in [`audience-commands.txt`](04-check-your-ollama/audience-commands.txt).
For an "exposed" (`*:11434`) screenshot, see [`make-screenshot-at-home.md`](04-check-your-ollama/make-screenshot-at-home.md). Never do that on conference Wi-Fi.

