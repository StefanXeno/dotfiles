# ============================================================
# OH-MY-ZSH SETUP
# ============================================================

export ZSH="$HOME/.oh-my-zsh"

# Disable OMZ theme — Starship handles the prompt entirely.
# Setting this to empty prevents OMZ from loading any theme,
# which saves startup time and avoids prompt conflicts.
ZSH_THEME=""

# zsh-autosuggestions highlight style.
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6272a4"

# History timestamp format
HIST_STAMPS="dd.mm.yyyy"

# OMZ Plugins
plugins=(
    autoupdate              # Auto-updates OMZ custom plugins (external, cloned by install.sh)
    colored-man-pages       # Colorize man pages
    sudo                    # Press ESC twice to prepend 'sudo' to last command
    zsh-autosuggestions     # Fish-like command suggestions (external, cloned by install.sh)
    zsh-syntax-highlighting # Command syntax highlighting (external, cloned by install.sh; must be last)
)

source "$ZSH/oh-my-zsh.sh"

# ============================================================
# PATH
# ============================================================

# typeset -U tells zsh to keep PATH entries unique.
# This automatically removes duplicates regardless of how many
# times PATH gets modified during shell initialization.
typeset -U PATH

# ============================================================
# MODULAR CONFIG
# Files live in ~/.zsh/ (stowed from zsh/.zsh/)
# ============================================================

ZSH_CONFIG_DIR="$HOME/.zsh"
for _zsh_module in options fzf aliases tmux completions k9s-functions; do
    [[ -f "$ZSH_CONFIG_DIR/${_zsh_module}.zsh" ]] && source "$ZSH_CONFIG_DIR/${_zsh_module}.zsh"
done
unset _zsh_module

# Bash completions compatibility layer — required by some tools (e.g. Terraform)
autoload -U +X bashcompinit && bashcompinit

# ============================================================
# LOCAL / PRIVATE CONFIG
# ============================================================

# Load machine-specific and private config if it exists.
# This file is NOT tracked in git.
# Put here: work email aliases, API keys, VPN aliases, proxy settings, etc.
# Template is created by install.sh on first run.

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ============================================================
# TOOL ACTIVATIONS
# Must come last — after all PATH modifications — so mise shims
# take precedence over everything else in PATH.
# ============================================================

eval "$(mise activate zsh)"

# direnv — watches for .envrc files and loads/unloads env vars automatically
eval "$(direnv hook zsh)"

# fzf shell integration (fzf 0.48+) — key bindings (Ctrl+R, Ctrl+T, Alt+C)
command -v fzf &>/dev/null && eval "$(fzf --zsh)"

# ============================================================
# PROMPT
# ============================================================

# Initialize Starship after mise so the [mise] module sees active tool versions.
eval "$(starship init zsh)"
