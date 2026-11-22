# Lab 04: dependency confusion (torchtriton)

Two package indexes, as two local folders. Same name, different versions.

```
source .venv/bin/activate

ls real-index fake-index
unzip -p fake-index/torchtriton-3.0.0-py3-none-any.whl torchtriton/__init__.py

pip install --no-index --find-links real-index --find-links fake-index torchtriton
python -c "import torchtriton"          # FAKE torchtriton 3.0.0 just ran on import
pip uninstall -y torchtriton

# The fix: pin the exact version and hash
cat requirements.txt
pip install --no-index --find-links real-index --find-links fake-index --require-hashes -r requirements.txt
python -c "import torchtriton; print(torchtriton.__version__)"    # 2.0.0
pip uninstall -y torchtriton
```
Offline. The fake package only prints a line.
