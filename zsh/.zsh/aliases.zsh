# shellcheck shell=bash
# Sourced by zsh — keep syntax bash-compatible where possible.

# --- Clipboard ---
# WSL2 → Windows clipboard via clip.exe; native Linux → xclip (needs DISPLAY) or wl-copy
clipcopy() {
    if grep -qi microsoft /proc/version 2>/dev/null && command -v clip.exe &>/dev/null; then
        clip.exe
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]] && command -v wl-copy &>/dev/null; then
        wl-copy
    elif [[ -n "${DISPLAY:-}" ]] && command -v xclip &>/dev/null; then
        xclip -selection clipboard
    else
        echo "clipcopy: no clipboard backend (WSL: clip.exe, Linux: DISPLAY+xclip or WAYLAND+wl-copy)" >&2
        return 1
    fi
}

_dunno_shrug() {
    echo -e '¯\_(ツ)_/¯' | clipcopy && echo 'Copied ¯\_(ツ)_/¯ to clipboard'
}
alias dunno='_dunno_shrug'
alias medunno='_dunno_shrug'
alias idk='_dunno_shrug'
alias idontknow='_dunno_shrug'

# --- Local tools ---
alias jqq='$HOME/tools/jqq/jqq.rb'
# Note: bfg version pinned here — update when you upgrade the jar
alias bfg='java -jar $HOME/tools/bfg/bfg-1.14.0.jar'

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

alias sl="sl -alFe"

# --- Modern CLI replacements (installed by mise, which is activated after this file loads,
# so these are functions that check at call time instead of `command -v` guards) ---
# OMZ ships ll/la as aliases, which would turn the function definitions below into parse errors.
unalias ll la 2>/dev/null
ll() { if command -v eza &>/dev/null; then eza -l --git --group-directories-first --icons=auto "$@"; else command ls -lh "$@"; fi; }
la() { if command -v eza &>/dev/null; then eza -la --git --group-directories-first --icons=auto "$@"; else command ls -lAh "$@"; fi; }
lt() { if command -v eza &>/dev/null; then eza --tree --level="${LT_LEVEL:-2}" --icons=auto "$@"; else tree -L "${LT_LEVEL:-2}" "$@"; fi; }
alias lg="lazygit"

# --- Docker ---
alias dcu="docker compose up -d"
alias dcd="docker compose down"

# --- Kubernetes ---
# Function wrapper (not alias) so tab completion works for `k`
if command -v kubectl &>/dev/null; then
    k() {
        command kubectl "$@"
    }
fi
alias kc="kubectx"
alias kns="kubens"

# --- helm-docs ---
alias hdoc="helm-docs"

# --- git ---
alias gl="git pull"
