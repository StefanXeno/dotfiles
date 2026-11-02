# Local AI Cheatsheet

Ollama runs on the Windows host, opencode in WSL. One AI provider serves every request (opencode and the shell helpers): Ollama with the model that is switched on, or an OpenAI-compatible server you configured. Nothing loads a model by itself except the menu and `opencode`.

## Shortcuts

| Action | Keys | What it does |
|---|---|---|
| AI chooser | `Ctrl+,` | Open the chooser: pick the AI provider, switch Ollama models on/off, keep-alive, opencode default |
| Explain command | `Ctrl+.` | Explain the current command line in a colored box that stays in the scrollback (any key cancels while it is generating) |
| Start opencode | `Ctrl+O` | Open opencode in the current directory (a half-typed line comes back afterwards) |
| Explain history entry | `Ctrl+R` | The history preview explains the focused command when a model is on |
| Scroll history preview | `Shift+↑` / `Shift+↓` | Scroll the explanation in the `Ctrl+R` preview (`Ctrl+/` toggles it) |
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
| `ai-chooser` | Open the AI chooser (same as `Ctrl+,`) |
| `ai-chooser provider` | List the providers, `●` = active |
| `ai-chooser provider NAME` | Make NAME the active provider for opencode and the shell helpers |
| `ai-chooser status` | List installed models, `●` = loaded |
| `ai-chooser load MODEL` | Load MODEL (unloads all others) and keep it on until switched off |
| `ai-chooser unload` | Unload all models and free the (V)RAM |
| `ai-chooser up` | Start Ollama on Windows if it is not reachable |
| `ai-chooser down` | Stop Ollama on Windows |
| `ai-chooser default MODEL` | Set the Ollama model MODEL as the opencode default, make ollama the active provider and reload opencode |
| `ollama-ai active` | Print the model of the active provider (the loaded one for Ollama) |
| `ollama-ai explain CMD` | Explain a shell command with the active model |
| `opencode` | Start opencode; starts Ollama and preloads the configured model first |
| `opencode run "PROMPT"` | One-shot prompt without the TUI |
| `opencode service get` | Show the env of the opencode background service (Ollama host, web search) |
| `opencode reload` | Reload the opencode config in the background service |
