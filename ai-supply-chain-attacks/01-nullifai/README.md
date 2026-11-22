# Lab 01: model file runs code (pickle, nullifAI)

```
source .venv/bin/activate

cat make_model.py
python make_model.py
python load_unsafe.py          # PWNED  -> loading the file ran a command
python load_safe.py            # Weights only load failed ... posix.system

cat make_broken.py
python make_broken.py
python -m pickletools evil.pkl # GLOBAL 'posix system' ... opcode b'\x00' unknown
python load_broken.py          # PWNED, then the error -> code ran before it broke

picklescan --path model.pt     # FOUND
picklescan --path evil.pkl     # FOUND

./reset.sh
```
