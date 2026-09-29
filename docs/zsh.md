# zsh & fzf

For commands and aliases, see [zsh Cheatsheet](cheatsheets/zsh-fzf.md).

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
| `Ctrl+R` | Search command history |
| `Ctrl+T` | Fuzzy-find files (multi-select with `Tab`) |
| `Ctrl+K` | Switch kubeconfig file via `kxd` (replaces default kill-line) |
| `Alt+C` | Fuzzy-find directories and `cd` into selection |
| `Alt+H` | Search dotfiles cheatsheets (`cs`) |

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

- Runs `kxd file switch` — promptui picker over files matching `KXD_MATCHER` in `~/.kube`
- Default matcher: `.conf,config.` (override in `~/.zshrc.local`)
- Selection persists via `~/.kxd` and is re-applied on every new shell

### Alt+C (directories)

- Preview shows `tree` of selected directory

### Alt+H (cheatsheets)

- Structured search: `git: Aliases - git st`
- Preview shows the command on top and a longer description below
- Override path with `DOTFILES_DIR`

## Local Overrides

Machine-specific config goes in `~/.zshrc.local` (not tracked in git):

```zsh
# Work aliases, API keys, proxy settings, etc.
```
