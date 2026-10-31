# zsh & fzf

For commands and aliases, see [zsh Cheatsheet](cheatsheets/zsh-fzf.md) and [Local AI Cheatsheet](cheatsheets/ai.md).

## Oh My Zsh Plugins

| Plugin | What it does |
|---|---|
| `zsh-autosuggestions` | Fish-like gray suggestions from history — accept with `→` |
| `zsh-syntax-highlighting` | Colors valid/invalid commands as you type |
| `sudo` | Press `Esc` twice to prepend `sudo` to the last command |
| `colored-man-pages` | Syntax-colored man pages |

Custom plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`) are pinned in `install.sh`.
Update them by bumping `OMZ_CUSTOM_PLUGIN_REFS` and re-running `install.sh`.

## Shell Options (from `options.zsh`)

| Behavior | How |
|---|---|
| `cd` without typing `cd` | `AUTO_CD` — type a directory path and Enter |
| Duplicate history entries | Ignored (`HIST_IGNORE_ALL_DUPS`) |
| History size | 50,000 entries |
| Syntax-colored `less` | Automatic via `source-highlight` |

## fzf Key Bindings

| Keys | Action |
|---|---|
| `Ctrl+R` | Search command history (preview explains the command when a local AI is on) |
| `Ctrl+T` | Fuzzy-find files (multi-select with `Tab`) |
| `Ctrl+K` | fzf kubeconfig picker via `kxd` (replaces default kill-line) |
| `Alt+C` | Fuzzy-find directories and `cd` into selection |
| `Ctrl+H` | Search dotfiles cheatsheets (`cs`) |

### Inside any fzf prompt

| Keys | Action |
|---|---|
| `Ctrl+/` | Toggle preview window |
| `Enter` | Confirm selection |
| `Esc` | Cancel |

### Ctrl+R (history)

- Preview shows the full command below the prompt
- Dracula-themed UI with `📖 Commands:` prompt

### Ctrl+T (files)

- Multi-select with `Tab`
- Preview: `tree` for directories, `bat` for files
- Respects `.gitignore` via `fd`

### Ctrl+K (kubeconfig)

- fzf picker over `kxd file list` (Dracula theme via `FZF_DEFAULT_OPTS`)
- Preview: `kubectl config get-contexts` for the highlighted file (local; no API call)
- Selecting a file runs `kxd <name>` so `KUBECONFIG` updates in the current shell
- Default matcher: `.conf,config.` (override in `~/.zshrc.local`)
- Selection persists via `~/.kxd` and is re-applied on every new shell
- Note: `kxd f s` still uses kxd's own promptui UI — Ctrl+K is the fzf path

### Alt+C (directories)

- Preview shows `tree` of selected directory

### Ctrl+H (cheatsheets)

- Structured search: `git: Aliases - git st`
- Preview shows the command on top and a longer description below
- Override path with `DOTFILES_DIR`

## Local AI (Ollama + opencode)

Ollama runs on the **Windows host** (exposed to the network); [opencode](https://opencode.ai) runs in WSL.
`ollama.zsh` exports `OLLAMA_WIN_HOST` (the WSL2 NAT default gateway — it changes after reboots).

| Keys / Command | Action |
|---|---|
| `Ctrl+,` | Ollama menu: model list with live status preview — `Enter` opens model options, `Ctrl+O` toggles on/off |
| `Ctrl+.` | Explain the current command line with the active model (speech bubble below the prompt) |
| `Ctrl+O` | Start opencode in the current directory |
| `Enter` / `Ctrl+O` / `Esc` | In the menu: model options / quick on/off / back or close |
| `ollama-menu status` | List models (`●` = loaded) |
| `ollama-menu load MODEL` / `unload [MODEL]` | Load (unloading all others) / unload without the menu |
| `opencode` | Starts Ollama if needed and preloads the configured model in the background |

- Model options: switch on/off, restart, keep-alive (until off / 1h / 30m / 5m), set as opencode default, set as default and start opencode.
- opencode 2 has no per-launch model flag — "start opencode" sets the default and runs `opencode reload` first.
- Models switched on in the menu stay loaded until switched off (`keep_alive: -1`, override with `OLLAMA_MENU_KEEP_ALIVE`).
- opencode config (`~/.config/opencode/opencode.json`) is per machine and not tracked here.

### AI in the shell

Uses only the model that is switched on (never loads one) and keeps its keep-alive:

- **Ctrl+R preview** — `ollama-ai explain` streams an explanation of the focused command into an 8-bit style speech bubble (cached in `~/.cache/dotfiles/ollama-explain`).
- **Ctrl+.** — explains the current command line in a speech bubble below the prompt (no colors: `zle -M` prints escape codes raw); a spinner runs behind the cursor, any key cancels. Without an active model it says so behind the cursor.
- **Autosuggestions** — `ZSH_AUTOSUGGEST_STRATEGY=(history ollama)`: when history has no match, the model completes the line from this session's recent commands (debounced, async, cancelled on the next key).
- **opencode web search** — `OPENCODE_ENABLE_EXA=1` enables the `websearch` tool (Exa, no API key; queries leave the machine). The wrapper syncs it and `OLLAMA_WIN_HOST` into the opencode background service env.
- `OLLAMA_AI_LANG` sets the explanation language (default English).

### Ctrl+, key path

Terminals do not send distinct sequences for `Ctrl+,` / `Ctrl+.`, and Windows Terminal uses `Ctrl+,` for *Settings*. Both use the same path (`Ctrl+.` sends `\e[46;5u`):

1. **Windows Terminal** ([`windows-terminal/settings.json`](../windows-terminal/settings.json), action `User.sendInput.OllamaMenu`) sends CSI-u `\e[44;5u` instead of opening *Settings*.
2. **tmux** parses it as `C-,` and would only pass `,` to the pane, so it re-sends the full sequence (`send-keys`).
3. **zsh**: `ollama.zsh` binds `\e[44;5u` to a zle widget that runs `ollama-menu` inline (like `Ctrl+T`).
