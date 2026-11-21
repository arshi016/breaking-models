# Breaking Models: AI supply-chain security labs

Live demos from my talk **"Breaking Models"**, one folder per section of the talk. New labs get added every week.

Everything here is **safe to run on your own laptop**:
- localhost only, nothing listens on `0.0.0.0`
- harmless payloads only (`echo PWNED`, `whoami`)
- nothing is pushed or uploaded anywhere

| Folder | Talk section | What you see |
|---|---|---|
| [`01-model-file-nullifai/`](01-model-file-nullifai/) | #1 Model file | Loading a `.pt` model runs a command. A broken pickle fools scanners (nullifAI). |
| [`04-pipeline-dependencies/`](04-pipeline-dependencies/) | #4 Pipeline & dependencies | GitHub Actions injection (Ultralytics), zizmor, Ray with no login (ShadowRay), check your Ollama. |

## How to run
Each section folder has a `PREREQUISITES.md` (install once). Each demo has a `README.md` with the commands to type.
Needs macOS or Linux and Python 3.10 to 3.12.
