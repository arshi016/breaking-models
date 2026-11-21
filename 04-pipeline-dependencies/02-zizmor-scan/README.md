# Demo 2: zizmor scan

**Before the talk (once):**
```
python3 -m venv .venv && .venv/bin/pip install zizmor
```

**On stage:**
```
source .venv/bin/activate

cat vulnerable-repo/.github/workflows/format.yml
zizmor --offline vulnerable-repo      # 2 high: line 2 and line 9

cat fixed-repo/.github/workflows/format.yml
zizmor --offline fixed-repo           # No findings
```
