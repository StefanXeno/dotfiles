# shellcheck shell=bash
# Sourced by zsh — keep syntax bash-compatible where possible.

_tmux_session_name() {
    basename "$PWD" | tr '. ' '__'
}

# List tmux sessions — fzf picker with window/pane preview
tl() {
    if ! command -v tmux &>/dev/null; then
        echo "tl: tmux not found" >&2
        return 1
    fi

    if ! tmux list-sessions &>/dev/null; then
        echo "tl: no tmux server running" >&2
        return 1
    fi

    if ! command -v fzf &>/dev/null; then
        tmux list-sessions
        return
    fi

    local selected
    selected="$(
        tmux list-sessions -F '#{session_name}	#{session_windows}w · #{session_attached} attached' \
            | fzf --delimiter=$'\t' --with-nth=1 \
                --prompt='🪟 Sessions: ' \
                --header='List tmux sessions — Enter to attach' \
                --preview-window 'right:60%:wrap' \
                --preview "bash -c '
                    session=\"\${1%%	*}\"
                    [[ -z \"\$session\" ]] && exit
                    echo \"Session: \$session\"; echo
                    while IFS= read -r win; do
                        wname=\$(tmux display-message -p -t \"\${session}:\${win}\" \"#{window_name}\" 2>/dev/null) || continue
                        active=\$(tmux display-message -p -t \"\${session}:\${win}\" \"#{?window_active, [active],}\" 2>/dev/null)
                        echo \"Window \${win}\${active}: \${wname}\"
                        tmux list-panes -t \"\${session}:\${win}\" -F \"  pane #{pane_index}: #{pane_current_command}\" 2>/dev/null
                        echo
                    done < <(tmux list-windows -t \"\$session\" -F \"#{window_index}\" 2>/dev/null)
                ' bash {}"
    )"

    [[ -z "$selected" ]] && return 0
    tmux attach-session -t "${selected%%$'\t'*}"
}

# New session (attach if name already exists). Default name: basename of $PWD.
# shellcheck disable=SC2120 # $1 is optional; default is derived from $PWD
tn() {
    local name="${1:-$(_tmux_session_name)}"
    if tmux has-session -t "$name" 2>/dev/null; then
        tmux attach-session -t "$name"
    else
        tmux new-session -s "$name"
    fi
}

# Attach to session — fzf picker when called without arguments
ta() {
    if [[ -n "${1:-}" ]]; then
        tmux attach-session -t "$1"
        return
    fi

    if ! command -v tmux &>/dev/null; then
        echo "ta: tmux not found" >&2
        return 1
    fi

    local sessions
    if ! sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null)"; then
        tn
        return
    fi

    local selected
    selected="$(
        {
            echo "$sessions"
            echo "[new session]"
        } | fzf --prompt='🪟 Sessions: ' --header='Attach to tmux session'
    )"

    case "$selected" in
        '') return 0 ;;
        '[new session]') tn ;;
        *) tmux attach-session -t "$selected" ;;
    esac
}
