# shellcheck shell=bash
# Sourced by zsh — keep syntax bash-compatible where possible.

# Dotfiles repo path (docs/cheatsheets/ is not stowed — lives only in the clone).
: "${DOTFILES_DIR:=$HOME/dotfiles}"
export DOTFILES_DIR

_CS_AWK="$DOTFILES_DIR/zsh/bin/cs-parse-cheatsheets.awk"
_CS_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/cs-entries.tsv"

_cs_dir() {
    local dir="$DOTFILES_DIR/docs/cheatsheets"
    if [[ ! -d "$dir" ]]; then
        echo "cs: cheatsheets not found at $dir (set DOTFILES_DIR?)" >&2
        return 1
    fi
    printf '%s\n' "$dir"
}

# Ubuntu ships 'batcat'; other distros use 'bat'. Works in subshells (no alias).
_cs_bat() {
    if command -v bat &>/dev/null; then
        command bat "$@"
    elif command -v batcat &>/dev/null; then
        command batcat "$@"
    else
        return 1
    fi
}

# Parse markdown tables/code into TSV rows (uncached).
_cs_parse_entries() {
    local dir="$1" f sheet
    if [[ ! -f "$_CS_AWK" ]]; then
        echo "cs: parser not found at $_CS_AWK" >&2
        return 1
    fi
    for f in "$dir"/*.md; do
        [[ -f "$f" ]] || continue
        sheet=$(basename "$f" .md)
        awk -v sheet="$sheet" -v file="$f" -f "$_CS_AWK" "$f"
    done
}

_cs_cache_stale() {
    local dir="$1"
    [[ -f "$_CS_CACHE" ]] || return 0
    local f
    for f in "$dir"/*.md "$_CS_AWK"; do
        [[ -f "$f" && "$f" -nt "$_CS_CACHE" ]] && return 0
    done
    return 1
}

_cs_build_cache() {
    local dir="$1" tmp
    mkdir -p "${_CS_CACHE%/*}" || return 1
    tmp="${_CS_CACHE}.tmp.$$"
    _cs_parse_entries "$dir" >"$tmp" || {
        rm -f "$tmp"
        return 1
    }
    mv -f "$tmp" "$_CS_CACHE"
}

# Return parsed cheatsheet rows, using a background-warmed cache when possible.
_cs_entries() {
    local dir="$1"
    if _cs_cache_stale "$dir"; then
        _cs_build_cache "$dir" || _cs_parse_entries "$dir"
    else
        cat "$_CS_CACHE"
    fi
}

# Warm cache after shell startup without blocking the prompt.
_cs_warm_cache() {
    local dir
    dir="$(_cs_dir)" || return 0
    if _cs_cache_stale "$dir"; then
        _cs_build_cache "$dir" &
    fi
}

# Fuzzy-pick a cheatsheet action; prints run_cmd to stdout.
_cs_pick() {
    local dir query selected run_cmd preview_body
    dir="$(_cs_dir)" || return 1
    query="${1:-}"

    if ! command -v fzf &>/dev/null; then
        _cs_entries "$dir" | cut -f1
        return 1
    fi

    selected="$(
        _cs_entries "$dir" \
            | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-}" fzf \
                --delimiter=$'\t' \
                --with-nth=1 \
                --prompt='📚 Cheatsheets: ' \
                --header='Enter: insert command/keys comment · Ctrl+/: preview · Esc: cancel' \
                --preview-window 'right:55%:wrap' \
                --preview 'printf "%b\n" {3}' \
                --bind 'ctrl-/:toggle-preview' \
                --bind 'focus:preview-top' \
                --query="$query"
    )"

    [[ -n "$selected" ]] || return 1

    run_cmd=$(printf '%s\n' "$selected" | cut -f2)
    preview_body=$(printf '%s\n' "$selected" | cut -f3)

    if [[ -z "$run_cmd" ]]; then
        if [[ -n "$preview_body" ]]; then
            echo "cs: no shell command for this entry — ${preview_body%%\\n*}" >&2
        else
            echo "cs: no shell command for this entry" >&2
        fi
        return 1
    fi

    printf '%s' "$run_cmd"
}

# Search dotfiles cheatsheets — inserts selected command into the prompt.
cs() {
    local run_cmd
    run_cmd="$(_cs_pick "${1:-}")" || return 1
    # shellcheck disable=SC3037 # print -z is zsh-only (insert into edit buffer)
    print -z -- "$run_cmd"
}

# Open a full cheatsheet file in bat/less.
cso() {
    local dir file bat_preview
    dir="$(_cs_dir)" || return 1

    if command -v bat &>/dev/null; then
        bat_preview='bat --color=always --style=numbers'
    elif command -v batcat &>/dev/null; then
        bat_preview='batcat --color=always --style=numbers'
    else
        bat_preview='cat'
    fi

    if ! command -v fzf &>/dev/null; then
        ls "$dir"/*.md 2>/dev/null
        return
    fi

    file="$(
        find "$dir" -maxdepth 1 -name '*.md' -printf '%f\n' 2>/dev/null \
            | sort \
            | fzf \
                --prompt='📖 Open: ' \
                --header='Pick a cheatsheet to read' \
                --preview "$bat_preview $dir/{} 2>/dev/null || cat $dir/{}"
    )"

    [[ -z "$file" ]] && return 0

    if _cs_bat --color=always --pager='less -R' "$dir/$file" 2>/dev/null; then
        return 0
    fi
    less -R "$dir/$file"
}

# Alt+H — fzf cheatsheet search (same family as Ctrl+R / Ctrl+T / Alt+C).
# shellcheck disable=SC1073,SC1072,SC1009 # zle widget bindings are zsh-only
_fzf_cheatsheet_widget() {
    local run_cmd
    run_cmd="$(_cs_pick)" || {
        zle reset-prompt
        return
    }
    LBUFFER=$run_cmd
    # shellcheck disable=SC2034 # CURSOR is read by zle after this assignment
    CURSOR=${#LBUFFER}
    zle reset-prompt
}

if [[ -o interactive && -t 0 && -o zle ]]; then
    zle -N _fzf_cheatsheet_widget
    bindkey '\eh' _fzf_cheatsheet_widget
fi

_cs_warm_cache
