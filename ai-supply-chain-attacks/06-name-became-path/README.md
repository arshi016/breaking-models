# Lab 06: the name became a path (Probllama)

Ollama saved each download as `blobs/<digest>`. The registry picks the digest.

```
python3 -c "import os; print(os.path.normpath('/root/.ollama/models/blobs/../../../../etc/ld.so.preload'))"
```
Output: `/etc/ld.so.preload`. It only prints a path. Nothing is written.
