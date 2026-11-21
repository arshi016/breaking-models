# Demo 4: check your own Ollama

```
echo $OLLAMA_HOST                     # empty = default, only you

lsof -nP -iTCP:11434 -sTCP:LISTEN     # 127.0.0.1:11434 = only you
                                      # *:11434         = every network door
                                      # Linux: ss -ltnp | grep 11434

curl -s http://localhost:11434/api/tags | jq -r '.models[].name'
                                      # no login, your models are listed
```
