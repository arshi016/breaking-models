# Prerequisites (install once)

```
python3.12 -m venv .venv && .venv/bin/pip install torch "numpy<2" picklescan==1.0.5
```
- Python 3.10 to 3.12. Intel Macs get torch 2.2.2 (the newest available there).
- On PyTorch 2.6+ the `load_safe.py` error says `unsupported GLOBAL posix.system`. Same meaning.
