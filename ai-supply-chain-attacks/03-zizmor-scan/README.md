# Lab 03: zizmor scan (Ultralytics)

```
source .venv/bin/activate

cat vulnerable-repo/.github/workflows/format.yml
zizmor --offline vulnerable-repo      # 2 high: line 2 and line 9

cat fixed-repo/.github/workflows/format.yml
zizmor --offline fixed-repo           # No findings
```
