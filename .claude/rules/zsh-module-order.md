---
description: Zsh module load order, OMZ plugins, and tool activation sequence
paths:
  - "zsh/**/*"
---

# Zsh Module Order

## `.zshrc` structure (top → bottom)

1. OMZ setup + `source "$ZSH/oh-my-zsh.sh"`
2. `typeset -U PATH`
3. Modular config loop (`zsh/.zsh/*.zsh`)
4. `bashcompinit`
5. `~/.zshrc.local` (private/machine-specific)
6. `mise activate` → `direnv hook` → `kxd init` (if installed) → `fzf --zsh` (TTY-guarded) → `zoxide init` → `starship init`

Tool activations **must** stay after `.zshrc.local` and all PATH changes so mise shims win.

`kxd init` must stay after `mise activate` (binary on PATH). Ctrl+K is an fzf widget
(not `kxd file switch` / promptui — that breaks under zle and skips Dracula theming).

## OMZ plugins

```zsh
plugins=(
    colored-man-pages
    sudo
    zsh-autosuggestions
    zsh-syntax-highlighting   # MUST be last
)
```

## Module loop order

```zsh
for _zsh_module in options fzf aliases tmux completions k9s-functions ollama cheatsheets; do
```

- Add new modules to this loop — do not `source` ad-hoc elsewhere in `.zshrc`.
- `cheatsheets` last among modules (registers Ctrl+H widget after fzf opts are set).

## New zsh files

| File | Location | shellcheck |
|---|---|---|
| Helpers, aliases, functions | `zsh/.zsh/<name>.zsh` | bash-compatible unless zsh-only |
| Scripts on PATH | `zsh/bin/<name>` | bash, `chmod +x` in `stow_dotfiles` |
