# Lab 4: hands up, yolo (nx s1ngularity)

```
grep -cE "yolo|dangerously-skip-permissions|trust-all-tools" ~/.zsh_history
```
Not zero? Hands up.

Fix: `npm config set ignore-scripts true` (nx ran from an install script).
