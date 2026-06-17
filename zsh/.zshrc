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

# OMZ Plugins:
# - 'fzf' plugin handles key bindings (Ctrl+R, Ctrl+T, Alt+C) via $FZF_BASE
plugins=(
    autoupdate          # Auto-updates OMZ custom plugins (external, cloned by install.sh)
    colored-man-pages   # Colorize man pages
    command-not-found   # Suggest package to install for unknown commands
    sudo                # Press ESC twice to prepend 'sudo' to last command
    zsh-autosuggestions # Fish-like command suggestions (external, cloned by install.sh)
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
# ENVIRONMENT
# ============================================================

# GPG_TTY is still needed if you use GPG for anything other than git signing
# (e.g. decrypting files, password managers). Remove if you go fully SSH-only.
export GPG_TTY=$(tty)

# less with syntax highlighting (requires source-highlight package)
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

# colorize plugin config (requires python3-pygments package)
ZSH_COLORIZE_TOOL=pygmentize
ZSH_COLORIZE_STYLE="colorful"

# ============================================================
# FZF CONFIGURATION
# ============================================================

# fzf shell integration — modern approach (fzf 0.48+)
# Loads key bindings (Ctrl+R, Ctrl+T, Alt+C) and completions directly
eval "$(fzf --zsh)"

# Dracula color scheme for fzf
export FZF_DEFAULT_OPTS="
--height=100%
--layout=reverse
--border=rounded
--margin=2
--padding=1
--info=inline
--prompt='🧛 '
--pointer='▶'
--marker='✓'
--color=fg:#f8f8f2,hl:#bd93f9
--color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9
--color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6
--color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
--color=border:#6272a4
"

export FZF_CTRL_R_OPTS="
--prompt='📖 Commands: '
--header='🔍 History Search'
--preview 'echo {}'
--preview-window down:3:hidden:wrap
--bind 'ctrl-/:toggle-preview'
--bind 'focus:preview-top'
"

export FZF_CTRL_T_OPTS="
--prompt='🗂️ Files: '
--header='📁 File Search - Use Tab for Multi-Select'
--preview 'if [ -d {} ]; then tree -C {} | head -200; else bat --color=always --style=numbers --line-range=:500 {} 2>/dev/null || cat {}; fi'
--preview-window right:50%
--bind 'ctrl-/:toggle-preview'
--bind 'focus:preview-top'
--multi
"

export FZF_ALT_C_OPTS="
--prompt='📂 Directories: '
--header='🏠 Directory Search'
--preview 'tree -C {} | head -200'
--bind 'ctrl-/:toggle-preview'
"

# ============================================================
# ALIASES
# ============================================================

# --- Clipboard ---
alias clipcopy='xclip -selection clipboard'
alias {dunno,medunno,idk,idontknow}='echo -e "¯\_(ツ)_/¯" | clipcopy && echo "Copied ¯\_(ツ)_/¯ to clipboard"'

# --- Local tools ---
alias jqq="$HOME/tools/jqq/jqq.rb"
# Note: bfg version pinned here — update when you upgrade the jar
alias bfg="java -jar $HOME/tools/bfg/bfg-1.14.0.jar"

# --- System ---
# On Ubuntu, 'fd' is installed as 'fdfind' to avoid conflicts with another package.
# On other distros it's just 'fd'. The conditional handles both.
if command -v fdfind &>/dev/null; then
    alias fd="fdfind"
fi

# On Ubuntu, 'bat' is installed as 'batcat' to avoid a name conflict.
# This alias makes 'bat' work everywhere.
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    alias bat="batcat"
fi

# Tool completions — loaded directly instead of via OMZ plugins
# for better control and to avoid redundant plugin overhead
command -v kubectl &>/dev/null && source <(kubectl completion zsh)
command -v helm    &>/dev/null && source <(helm completion zsh)
command -v docker  &>/dev/null && source <(docker completion zsh)

# fzf shell integration — sourced directly from mise install path
[[ -f "$(mise where fzf)/shell/key-bindings.zsh"  ]] && source "$(mise where fzf)/shell/key-bindings.zsh"
[[ -f "$(mise where fzf)/shell/completion.zsh"    ]] && source "$(mise where fzf)/shell/completion.zsh"

alias sl="sl -alFe"

# --- Docker ---
alias dcu="docker compose up -d"
alias dcd="docker compose down"

# --- Kubernetes ---
alias k="kubectl"
alias kc="kubectx"
alias kns="kubens"

# --- helm-docs ---
alias hdoc="helm-docs"

# ============================================================
# TOOL INTEGRATIONS
# ============================================================

# direnv — watches for .envrc files and loads/unloads env vars automatically
eval "$(direnv hook zsh)"

# Load custom k9s shell functions (file managed via stow alongside this .zshrc)
[[ -f ~/.zsh/k9s-functions.zsh ]] && source ~/.zsh/k9s-functions.zsh

# ============================================================
# PROMPT
# ============================================================

# Initialize Starship prompt.
# Must come AFTER all OMZ setup (especially the mise plugin activation)
# so that PATH and shims are ready before starship runs.
eval "$(starship init zsh)"

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