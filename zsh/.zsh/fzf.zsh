# shellcheck shell=bash
# Sourced by zsh — keep syntax bash-compatible where possible.

# fzf shell integration is loaded after 'mise activate' (see .zshrc)
# so the mise-managed fzf binary is on PATH first.

# Prefer fd over find (respects .gitignore) — for Ctrl+T and Alt+C too, not only the default.
_fzf_fd=""
if command -v fd &>/dev/null; then
    _fzf_fd=fd
elif command -v fdfind &>/dev/null; then
    _fzf_fd=fdfind
fi
if [[ -n "$_fzf_fd" ]]; then
    export FZF_DEFAULT_COMMAND="$_fzf_fd --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$_fzf_fd --hidden --follow --exclude .git"
    export FZF_ALT_C_COMMAND="$_fzf_fd --type d --hidden --follow --exclude .git"
fi
unset _fzf_fd

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

# Ctrl+R: the preview takes the space below the list (FZF_HISTORY_LIST_ROWS rows, default 10) but
# never more than half of the screen (FZF_LINES excludes 8 rows of margin/border/padding; 2 rows are
# prompt and header), and at least 8 rows. On resize (terminal, tmux split) the window is recomputed
# and the preview re-run, so the card gets the new width and height.
# Preview: ollama-ai explains the command when a local model is switched on (see ollama.zsh).
export FZF_CTRL_R_OPTS="
--prompt='📖 Commands: '
--header='🔍 History Search · Ctrl+/ preview · Shift+↑↓ scroll preview'
--preview 'if command -v ollama-ai >/dev/null 2>&1; then ollama-ai explain {2..}; else echo {} | fold -sw 120; fi'
--preview-window down:60%:wrap:border-none
--bind 'start,resize:transform:echo \"change-preview-window(down,\$(( p = FZF_LINES - ${FZF_HISTORY_LIST_ROWS:-10} - 2, h = (FZF_LINES + 8) / 2, n = p > h ? h : p, n < 8 ? 8 : n )),wrap,border-none)+refresh-preview\"'
--bind 'ctrl-/:toggle-preview'
--bind 'shift-up:preview-half-page-up,shift-down:preview-half-page-down'
--bind 'focus:preview-top'
"

export FZF_CTRL_T_OPTS="
--prompt='🗂️ Files: '
--header='📁 File Search - Use Tab for Multi-Select'
--preview 'if [ -d {} ]; then if command -v eza >/dev/null 2>&1; then eza --tree --level=2 --color=always {}; else tree -C {}; fi | head -200; elif command -v bat >/dev/null 2>&1; then bat --color=always --style=numbers --line-range=:500 {}; elif command -v batcat >/dev/null 2>&1; then batcat --color=always --style=numbers --line-range=:500 {}; else cat {}; fi'
--preview-window right:50%
--bind 'ctrl-/:toggle-preview'
--bind 'focus:preview-top'
--multi
"

export FZF_ALT_C_OPTS="
--prompt='📂 Directories: '
--header='🏠 Directory Search'
--preview 'if command -v eza >/dev/null 2>&1; then eza --tree --level=2 --color=always {}; else tree -C {}; fi | head -200'
--bind 'ctrl-/:toggle-preview'
"

# rgf [pattern] — live ripgrep through fzf; Enter opens the match in $EDITOR at that line.
# rg is installed by mise (activated after this file loads), so it is checked at call time.
rgf() {
    command -v rg &>/dev/null || { echo "rgf: ripgrep (rg) not found" >&2; return 1; }
    local rg_cmd='rg --column --line-number --no-heading --color=always --smart-case'
    local selection file line editor start_cmd=true
    # No pattern yet: list nothing instead of every line of the tree.
    [[ -n "$*" ]] && start_cmd="$rg_cmd -- $(printf '%q' "$*")"
    selection="$(
        FZF_DEFAULT_COMMAND="$start_cmd" fzf --ansi --disabled --query "$*" \
            --prompt='🔎 rg: ' \
            --bind "change:reload:$rg_cmd -- {q} || true" \
            --delimiter : \
            --preview 'if command -v bat >/dev/null 2>&1; then bat --color=always --style=numbers --highlight-line {2} {1}; elif command -v batcat >/dev/null 2>&1; then batcat --color=always --style=numbers --highlight-line {2} {1}; else cat {1}; fi' \
            --preview-window 'right:55%:+{2}+3/3,~3'
    )" || return 0
    [[ -n "$selection" ]] || return 0
    IFS=: read -r file line _ <<<"$selection"
    editor="${EDITOR:-$(command -v nvim || echo vim)}"
    "$editor" "+$line" "$file"
}
