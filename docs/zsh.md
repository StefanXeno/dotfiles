# zsh & fzf

For commands and aliases, see [zsh Cheatsheet](cheatsheets/zsh-fzf.md), [Local AI Cheatsheet](cheatsheets/ai.md) and [Windows Terminal Cheatsheet](cheatsheets/windows-terminal.md).

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
| `Ctrl+,` | AI chooser: first row picks the AI provider, then the Ollama model list with live status preview — `Enter` opens model options, `Ctrl+O` toggles on/off |
| `Ctrl+.` | Explain the current command line with the active model (colored box, stays in the scrollback) |
| `Ctrl+O` | Start opencode in the current directory |
| `Enter` / `Ctrl+O` / `Esc` | In the menu: model options / quick on/off / back or close |
| `ai-chooser provider [NAME]` | List the providers / make NAME the active one |
| `ai-chooser status` | List models (`●` = loaded) |
| `ai-chooser load MODEL` / `unload [MODEL]` | Load (unloading all others) / unload without the menu |
| `opencode` | Starts Ollama if needed and preloads the configured model in the background |

- Model options: switch on/off, restart, keep-alive (until off / 1h / 30m / 5m), set as opencode default, set as default and start opencode.
- opencode 2 has no per-launch model flag — "start opencode" sets the default and runs `opencode reload` first.
- Models switched on in the menu stay loaded until switched off (`keep_alive: -1`, override with `AI_CHOOSER_KEEP_ALIVE`).
- opencode config (`~/.config/opencode/opencode.json`) is per machine and not tracked here.

### AI providers

One provider serves every AI request: opencode, the `Ctrl+R` / `Ctrl+.` explanations and the autosuggestions. `ollama` (Ollama on the Windows host) is built in. More providers go into `~/.config/ai/providers.local.json` — a per-machine file that is never committed, because it holds endpoints and the names of key variables:

```json
{
  "my-server": {
    "type": "openai",
    "url": "https://ai.example.com/v1",
    "model": "my-model",
    "key_env": "MY_SERVER_KEY",
    "trust": "trusted"
  }
}
```

- `type` is `ollama` or `openai` (any OpenAI-compatible `/chat/completions` server). `key_env` names an environment variable (for example exported in `~/.zshrc.local`); the key itself is never written to a file. `trust` (`local` / `trusted` / `cloud`) is reserved for confirming cloud providers later.
- Optional: `extra_body` is merged into every chat request. For opencode, `name`, `timeout` and a `models` block (limits, capabilities) are copied into its provider.
- The choice is stored in `~/.local/state/ai/active`. For opencode, `ai-chooser` generates `~/.local/state/ai/opencode.json` (key as `{env:NAME}`, mode 600); the `opencode` wrapper passes it as `OPENCODE_CONFIG` on top of the repo config, which stays a neutral template.
- A plain `http://` URL to another host is flagged: prompts and the key would cross the network unencrypted. A key variable that is not set in the shell is flagged too.
- Autosuggestions fire after every pause in typing, so an active remote provider receives your command lines and recent history all the time. Pick `ollama` when that is not wanted.
- The opencode background service does not inherit your shell's key variable. The wrapper deliberately does not copy it there (the service would store it); set it with `opencode service set env NAME VALUE` if opencode cannot see the key.

### AI in the shell

Uses the active provider (never loads an Ollama model) and keeps the model's keep-alive:

- **Ctrl+R preview** — `ollama-ai explain` streams an explanation of the focused command into a rounded, colored box (cached in `~/.cache/dotfiles/ollama-explain`).
- **Ctrl+.** — explains the current command line: a spinner runs behind the cursor while the answer streams uncolored below the prompt (`zle -M` prints escape codes raw), then the colored box is printed into the scrollback; any key cancels. Without an active model it says so behind the cursor.
- **Autosuggestions** — `ZSH_AUTOSUGGEST_STRATEGY=(history ollama)`: when history has no match, the model completes the line from this session's recent commands (debounced, async, cancelled on the next key).
- **opencode web search** — `OPENCODE_ENABLE_EXA=1` enables the `websearch` tool (Exa, no API key; queries leave the machine). The wrapper syncs it and `OLLAMA_WIN_HOST` into the opencode background service env.
- `OLLAMA_AI_LANG` sets the explanation language (default English).
- **Your shortcuts** — `ollama.zsh` writes your aliases and the functions from `~/.zsh/` / `~/.zshrc*` to `~/.cache/dotfiles/ollama-context/` (once after the first prompt, and before every `Ctrl+.`). `ollama-ai` looks up the first word of every command in a pipeline/list there, plus `git` aliases from `.gitconfig`, and hands the definitions to the model. The card shows them as `↳ alias lg → lazygit`. Typing only a directory name is understood as zsh `AUTO_CD` (`cd`), together with a short listing of the directory.
- **Ctrl+R layout** — the preview sits below the list and takes the space left after `FZF_HISTORY_LIST_ROWS` list rows (default 10), but never more than half of the screen (and at least 8 rows); the card is drawn exactly that tall and as wide as the pane. The header and command appear at once, the explanation when the model is done.
- **Usage and model in tmux** — inside tmux the starship prompt hides the Claude usage (`✻ 23% 3h03m`) and the loaded Ollama model; the tmux status bar shows them instead (`zsh/bin/tmux-ai-status`, appended to `status-right` after the Dracula theme). Each part appears only while it exists: no Claude window with usage, no loaded model, no segment (and no empty colored block).
- **Answer size** — short commands get up to 5 parts / 300 tokens; "big" ones (several lines, more than 120 characters, or 3+ pipes) get up to 14 parts / 1000 tokens. Tune with `OLLAMA_AI_PARTS_SHORT`, `OLLAMA_AI_PARTS_LONG`, `OLLAMA_AI_TOKENS_SHORT`, `OLLAMA_AI_TOKENS_LONG` and `OLLAMA_AI_LONG_CHARS` (e.g. in `~/.zshrc.local`).

### Ctrl+, key path

Terminals do not send distinct sequences for `Ctrl+,` / `Ctrl+.`, and Windows Terminal uses `Ctrl+,` for *Settings*. Both use the same path (`Ctrl+.` sends `\e[46;5u`):

1. **Windows Terminal** ([`windows-terminal/settings.json`](../windows-terminal/settings.json), action `User.sendInput.OllamaMenu`) sends CSI-u `\e[44;5u` instead of opening *Settings*.
2. **tmux** parses it as `C-,` and would only pass `,` to the pane, so it re-sends the full sequence (`send-keys`).
3. **zsh**: `ollama.zsh` binds `\e[44;5u` to a zle widget that runs `ai-chooser` inline (like `Ctrl+T`).

## Windows Terminal settings

`windows-terminal/settings.json` is the source of truth, but it is **not stowed** — Windows Terminal starts
before WSL is guaranteed to be reachable, so a symlink into WSL is fragile. `wt-settings` syncs it instead
(`install.sh` runs `push` on WSL):

| Command | Action |
|---|---|
| `wt-settings` | Check whether live settings and repo match |
| `wt-settings diff` | Show what differs (live → repo) |
| `wt-settings push` | Repo → Windows (live file is backed up next to it) |
| `wt-settings pull` | Windows → repo — run after changing settings in the Settings UI, then commit |

## Local Overrides

Machine-specific config goes in `~/.zshrc.local` (not tracked in git):

```zsh
# Work aliases, API keys, proxy settings, etc.
```
