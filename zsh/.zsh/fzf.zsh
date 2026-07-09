# shellcheck shell=bash
# Sourced by zsh — keep syntax bash-compatible where possible.

# fzf shell integration is loaded after 'mise activate' (see .zshrc)
# so the mise-managed fzf binary is on PATH first.

# Prefer fd over find (respects .gitignore)
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
elif command -v fdfind &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
fi

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
--preview 'echo {} | fold -sw 120'
--preview-window down:5:wrap
--bind 'ctrl-/:toggle-preview'
--bind 'focus:preview-top'
"

export FZF_CTRL_T_OPTS="
--prompt='🗂️ Files: '
--header='📁 File Search - Use Tab for Multi-Select'
--preview 'if [ -d {} ]; then tree -C {} | head -200; elif command -v bat >/dev/null 2>&1; then bat --color=always --style=numbers --line-range=:500 {}; elif command -v batcat >/dev/null 2>&1; then batcat --color=always --style=numbers --line-range=:500 {}; else cat {}; fi'
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
