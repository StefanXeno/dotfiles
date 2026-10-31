# Local AI Cheatsheet

Ollama runs on the Windows host, opencode in WSL. Everything uses the model that is switched on — nothing loads a model by itself except the menu and `opencode`.

## Shortcuts

| Action | Keys | What it does |
|---|---|---|
| Ollama menu | `Ctrl+,` | Open the model menu: live status preview, switch models on/off, keep-alive, opencode default |
| Explain command | `Ctrl+.` | Explain the current command line in a speech bubble below the prompt (any key cancels) |
| Start opencode | `Ctrl+O` | Open opencode in the current directory (a half-typed line comes back afterwards) |
| Explain history entry | `Ctrl+R` | The history preview explains the focused command when a model is on |
| Accept AI suggestion | `→` / `End` | Accept the grey autosuggestion (history first, then the local AI completes the line) |

## Ollama menu (Ctrl+,)

| Action | Keys | What it does |
|---|---|---|
| Model options | `Enter` | Open the options of the focused model (on/off, restart, keep-alive, opencode default) |
| Quick on/off | `Ctrl+O` | Switch the focused model on or off without opening its options |
| Run option | `Enter` | Inside the model options: run the focused option (fzf shows a spinner while it loads) |
| Back / close | `Esc` | Leave the model options, or close the menu |
| Filter | type | Fuzzy-filter models or options |

## Commands

| Command | What it does |
|---|---|
| `ollama-menu` | Open the Ollama model menu (same as `Ctrl+,`) |
| `ollama-menu status` | List installed models, `●` = loaded |
| `ollama-menu load MODEL` | Load MODEL (unloads all others) and keep it on until switched off |
| `ollama-menu unload` | Unload all models and free the (V)RAM |
| `ollama-menu up` | Start Ollama on Windows if it is not reachable |
| `ollama-menu down` | Stop Ollama on Windows |
| `ollama-menu default MODEL` | Set MODEL as the opencode default and reload opencode |
| `ollama-ai active` | Print the model that is currently switched on |
| `ollama-ai explain CMD` | Explain a shell command with the active model |
| `opencode` | Start opencode; starts Ollama and preloads the configured model first |
| `opencode run "PROMPT"` | One-shot prompt without the TUI |
| `opencode service get` | Show the env of the opencode background service (Ollama host, web search) |
| `opencode reload` | Reload the opencode config in the background service |
