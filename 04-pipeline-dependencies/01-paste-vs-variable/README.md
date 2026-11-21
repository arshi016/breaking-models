# Demo 1: paste vs variable

GitHub Actions copies your `run:` line into a script file, then runs it with bash.
Here you do the same thing by hand. Type each line.

**1. The attacker's branch name**
```
export BRANCH='$(echo PWNED)'
```

**2. Unsafe: `run: echo Building ${{ github.head_ref }}`**
```
echo "echo Building $BRANCH" > ci.sh
cat ci.sh        # echo Building $(echo PWNED)   <- attacker text is IN the script
bash ci.sh       # Building PWNED                <- it ran
```

**3. Safe: `env: BRANCH` + `run: echo "Building $BRANCH"`**
```
echo 'echo "Building $BRANCH"' > ci.sh
cat ci.sh        # echo "Building $BRANCH"       <- script only has a variable
bash ci.sh       # Building $(echo PWNED)        <- it printed
```

**Say:** Pasted, it runs. Variable, it prints.

Clean up: `./reset.sh`
