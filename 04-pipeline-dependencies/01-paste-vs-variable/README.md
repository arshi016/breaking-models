# Demo 1: paste vs variable

Type these 3 lines.

```
BRANCH='$(echo PWNED)'
bash -c "echo Building $BRANCH"     # like ${{ }}   -> Building PWNED
echo "Building $BRANCH"             # like env:     -> Building $(echo PWNED)
```

**Say:** Pasted, it runs. Variable, it prints.
