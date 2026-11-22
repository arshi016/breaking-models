# Lab 2: tool poisoning ("Adds two numbers")

```
source .venv/bin/activate

# What the AI sees: the full tool description
npx @modelcontextprotocol/inspector --cli python server.py --method tools/list | jq -r '.tools[].description'
```
The server only adds numbers. It reads nothing and sends nothing.
