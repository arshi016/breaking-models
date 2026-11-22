# Lab 04: dependency confusion (torchtriton)

pip is set up with two package indexes (two local folders): one has the real `torchtriton 2.0.0`, one has a fake `3.0.0`.

```
source .venv/bin/activate

cat pip.conf                     # two indexes, like PyPI + PyTorch's own index

pip install torchtriton          # pip picks the higher version: the fake one
python -c "import torchtriton"   # FAKE torchtriton 3.0.0 just ran on import
pip uninstall -y torchtriton

cat requirements.txt             # the fix: exact version + hash
pip install -r requirements.txt  # installs the real 2.0.0
pip uninstall -y torchtriton
```
Offline. The fake package only prints a line.
