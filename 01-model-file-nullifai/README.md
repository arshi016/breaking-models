# #1 Model file: pickle and nullifAI

A PyTorch `.pt` file holds a pickle, and loading a pickle can call any function. nullifAI (ReversingLabs, Feb 2025) went one step further: break the file at the end. The payload still runs, but old scanners gave up on the broken file and reported nothing.

```
./setup.sh    # once: torch + picklescan in .venv
./run.sh
./reset.sh
```

| File | What it does |
|---|---|
| `make_model.py` | Saves `model.pt` with real weights and a hidden `echo PWNED` |
| `load_unsafe.py` | `torch.load(..., weights_only=False)`: prints `PWNED` |
| `load_safe.py` | `torch.load(..., weights_only=True)`: refuses to load |
| `make_broken.py` | Writes `evil.pkl` with its last byte broken (nullifAI) |

## Expected output
```
$ python load_unsafe.py
PWNED
loaded

$ python load_safe.py
Weights only load failed
Unsupported class posix.system

$ python -c "import pickle; pickle.load(open('evil.pkl', 'rb'))"
PWNED
_pickle.UnpicklingError: invalid load key, '\x00'.

$ picklescan --path evil.pkl
evil.pkl: dangerous import 'posix system' FOUND
Infected files: 1
```
On PyTorch 2.6+ the error says `Trying to load unsupported GLOBAL posix.system`. Same meaning. Intel Macs can only install torch 2.2.2.

**What to say:** Just loading the file ran a command. The broken file failed to load, but the command had already run.
