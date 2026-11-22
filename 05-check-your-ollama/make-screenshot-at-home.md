# Backup slide: capture an "exposed" Ollama at home

Do this **only on your home network**, never on conference Wi-Fi. It opens Ollama to the network for about one minute.

## 1. Quit Ollama
Quit it from the menu bar icon. Check that nothing is listening:
```
lsof -nP -iTCP:11434 -sTCP:LISTEN      # should print nothing
```

## 2. Start it open to the network, in one terminal
```
OLLAMA_HOST=0.0.0.0:11434 ollama serve
```
The setting lives only in this terminal. Nothing is saved.

## 3. In a second terminal, take the screenshot
```
lsof -nP -iTCP:11434 -sTCP:LISTEN
```
Expected: `ollama ... TCP *:11434 (LISTEN)`. Screenshot that line.

## 4. Undo right away
- Press `Ctrl+C` in the first terminal.
- Check that it is closed:
```
lsof -nP -iTCP:11434 -sTCP:LISTEN      # should print nothing
```
- Open the Ollama app again. It goes back to `127.0.0.1:11434`.

## Do not
- Do not run `launchctl setenv OLLAMA_HOST 0.0.0.0`. That one stays after you close the terminal.
- Do not use `docker run -p 11434:11434`. If you use Docker, write `-p 127.0.0.1:11434:11434`.
