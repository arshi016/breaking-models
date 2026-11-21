# Backup: real output of every demo

Captured 2026-11-21 on macOS (Intel), zizmor 1.32.0, Ray 2.49.2. Use these if Wi-Fi or a tool dies on stage.

## Demo 1: paste vs variable
```
$ BRANCH='$(echo PWNED)'
$ bash -c "echo Building $BRANCH"
Building PWNED
$ echo "Building $BRANCH"
Building $(echo PWNED)
```

## Demo 2: zizmor scan
```
$ cat vulnerable-repo/.github/workflows/format.yml
name: format
on: pull_request_target
permissions:
  contents: write
jobs:
  format:
    runs-on: ubuntu-latest
    steps:
      - run: echo "Building ${{ github.head_ref }}"

$ zizmor --offline vulnerable-repo
error[dangerous-triggers]: use of fundamentally insecure workflow trigger
 --> vulnerable-repo/.github/workflows/format.yml:2:1
error[template-injection]: code injection via template expansion
 --> vulnerable-repo/.github/workflows/format.yml:9:33
6 findings (4 suppressed, 1 unsafe fixes): 0 informational, 0 low, 0 medium, 2 high

$ cat fixed-repo/.github/workflows/format.yml
name: format
on: pull_request
permissions: {}
jobs:
  format:
    runs-on: ubuntu-latest
    steps:
      - env:
          BRANCH: ${{ github.head_ref }}
        run: echo "Building $BRANCH"

$ zizmor --offline fixed-repo
No findings to report. Good job! (2 suppressed)
```

## Demo 3: Ray with no login
```
$ ray start --head --dashboard-host 127.0.0.1 --disable-usage-stats
Ray runtime started.

$ ray job submit --address http://127.0.0.1:8265 -- whoami
warmearthling
Job 'raysubmit_XfUWNL2X6ASAmq9q' succeeded
```

## Demo 4: check your own Ollama
```
OLLAMA_HOST = not set (default: 127.0.0.1)

$ lsof -nP -iTCP:11434 -sTCP:LISTEN
COMMAND   PID          USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
ollama  34570 warmearthling    4u  IPv4 0xb32be96c2e2d9994      0t0  TCP 127.0.0.1:11434 (LISTEN)

$ curl -s http://localhost:11434/api/tags | jq -r '.models[].name'
llama3.1:8b
```

- Demo 3 on Ray 2.59+ also prints a `WARNING` line saying token authentication is disabled.
- Demo 4 model list trimmed to one model.
