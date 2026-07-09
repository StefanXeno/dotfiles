# zsh & fzf Cheatsheet

## Oh My Zsh Plugins

| Plugin | What it does |
|---|---|
| `zsh-autosuggestions` | Fish-like gray suggestions from history — accept with `→` |
| `zsh-syntax-highlighting` | Colors valid/invalid commands as you type |
| `sudo` | Press `Esc` twice to prepend `sudo` to the last command |
| `colored-man-pages` | Syntax-colored man pages |
| `autoupdate` | Auto-updates OMZ custom plugins |

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
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Fuzzy-find files (multi-select with `Tab`) |
| `Alt+C` | Fuzzy-find directories and `cd` into selection |

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

### Alt+C (directories)

- Preview shows `tree` of selected directory

## Aliases

### Clipboard

| Alias | Action |
|---|---|
| `clipcopy` | Pipe to clipboard (`clip.exe` on WSL2, `xclip`/`wl-copy` on native Linux; needs a display — not in headless Docker) |
| `dunno` / `idk` / `medunno` | Copy `¯\_(ツ)_/¯` to clipboard |

### System

| Alias | Action |
|---|---|
| `fd` | Maps to `fdfind` on Ubuntu |
| `bat` | Maps to `batcat` on Ubuntu |
| `sl` | Important train (`sl -alFe`) |

### Docker

| Alias | Action |
|---|---|
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |

### tmux

| Command | Action |
|---|---|
| `tl` | List sessions (fzf + window/pane preview; Enter attaches) |
| `tn [name]` | New session (default name: basename of `$PWD`; attach if exists) |
| `ta [name]` | Attach to session; without name → fzf picker |

### Kubernetes

| Command | Action |
|---|---|
| `k` | `kubectl` wrapper (tab completion works) |
| `kc` | `kubectx` — switch cluster context |
| `kns` | `kubens` — switch namespace |

### Tools

| Alias | Action |
|---|---|
| `hdoc` | `helm-docs` |
| `jqq` | Local JSON query tool |
| `bfg` | BFG Repo-Cleaner |

## k9s Helpers

| Function | Action |
|---|---|
| `k9s-node-shell-on` | Enable `K9S_FEATURE_GATE_NODE_SHELL=true` |
| `k9s-node-shell-off` | Unset the feature gate |

## Local Overrides

Machine-specific config goes in `~/.zshrc.local` (not tracked in git):

```zsh
# Work aliases, API keys, proxy settings, etc.
```

## Useful Commands

```bash
exec zsh                    # reload shell after config changes
mise ls                     # show installed tool versions
direnv allow                # approve .envrc in current directory
```
