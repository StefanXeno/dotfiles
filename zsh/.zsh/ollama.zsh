# shellcheck shell=bash
# Sourced by zsh — keep syntax bash-compatible where possible.
# Local AI: Ollama runs on the Windows host, opencode runs in WSL (see zsh/bin/ai-chooser).

# WSL2 NAT mode: the Windows host is the default gateway (changes after reboots).
OLLAMA_WIN_HOST="$(ip route show default 2>/dev/null | awk '{print $3; exit}')"
export OLLAMA_WIN_HOST

[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

# opencode web search (Exa, no API key) — also needed for local models.
export OPENCODE_ENABLE_EXA=1

# opencode 2 runs a background service with its own persistent env. The config's
# Ollama baseURL uses {env:OLLAMA_WIN_HOST}, so keep that env in sync with the current IP.
_opencode_sync_service_env() {
    local env
    env="$(command opencode service get 2>/dev/null)" || return 0
    if [[ "$(jq -r '.env.OLLAMA_WIN_HOST // empty' <<<"$env")" != "$OLLAMA_WIN_HOST" ||
        "$(jq -r '.env.OPENCODE_ENABLE_EXA // empty' <<<"$env")" != "$OPENCODE_ENABLE_EXA" ]]; then
        command opencode service set env OLLAMA_WIN_HOST "$OLLAMA_WIN_HOST" >/dev/null
        command opencode service set env OPENCODE_ENABLE_EXA "$OPENCODE_ENABLE_EXA" >/dev/null
        command opencode service restart >/dev/null 2>&1
    fi
}

# opencode wrapper: start Ollama if needed and preload the model in the background,
# so the first answer does not wait for a cold model load.
opencode() {
    # `type -p` (zsh and bash) only finds the program: `command -v` would find this function.
    if ! type -p opencode &>/dev/null; then
        echo "opencode is not installed (https://opencode.ai)" >&2
        return 127
    fi
    local model="" prev="" arg
    for arg in "$@"; do
        case "$prev" in -m | --model) model="$arg" ;; esac
        case "$arg" in --model=*) model="${arg#--model=}" ;; esac
        prev="$arg"
    done
    [[ -z "$model" ]] && model="$(jq -r '.model // empty' "$HOME/.config/opencode/opencode.json" 2>/dev/null)"

    # Start Ollama and preload the model only when opencode will actually use a local model.
    if [[ "$model" == ollama/* ]] && command -v ai-chooser &>/dev/null; then
        ai-chooser up
        (ai-chooser load "${model#ollama/}" >/dev/null 2>&1 &)
    fi

    _opencode_sync_service_env
    command opencode "$@"
}

# Ctrl+, — Ollama model menu. Windows Terminal sends CSI-u "\e[44;5u" for Ctrl+,
# (sendInput action); tmux re-sends it to the pane (see tmux/.tmux.conf).
# shellcheck disable=SC1073,SC1072,SC1009 # zle widget bindings are zsh-only
_ollama_menu_widget() {
    local cmd_file cmd
    cmd_file="$(mktemp)"
    zle -I
    AI_CHOOSER_CMD_FILE="$cmd_file" ai-chooser </dev/tty
    cmd="$(<"$cmd_file")"
    rm -f "$cmd_file"
    # "Start opencode" picked in the menu: run it in this shell (keeps history and wrapper).
    if [[ -n "$cmd" ]]; then
        # shellcheck disable=SC2034 # BUFFER is read by zle accept-line
        BUFFER="$cmd"
        zle accept-line
        return
    fi
    zle reset-prompt
}

if [[ -o interactive && -t 0 && -o zle ]]; then
    zle -N _ollama_menu_widget
    bindkey '\e[44;5u' _ollama_menu_widget
fi

# zsh-autosuggestions strategy: ask the active local model when history has no match.
# Runs in the plugin's async child, which is killed on the next keystroke — the sleep
# debounces typing so only a paused prompt reaches the model.
_zsh_autosuggest_strategy_ollama() {
    typeset -g suggestion
    (( ${#1} >= 3 )) || return
    command -v ollama-ai &>/dev/null || return
    sleep 0.4
    # -I: only this session's commands (not those loaded from $HISTFILE).
    # shellcheck disable=SC2034 # read by zsh-autosuggestions
    suggestion="$( { fc -lnI -30 2>/dev/null || fc -ln -30; } | ollama-ai complete "$1" "$PWD")"
}

if [[ -o interactive ]]; then
    # shellcheck disable=SC2034 # read by zsh-autosuggestions
    ZSH_AUTOSUGGEST_STRATEGY=(history ollama)
fi

# Ctrl+. — explain the current command line with the active local model.
# Windows Terminal sends CSI-u "\e[46;5u" (tmux re-sends it). A spinner runs behind the
# cursor while the answer streams into an uncolored box below the prompt (zle -M prints
# colors raw); when done, the colored box is printed into the scrollback. Any key cancels
# and is replayed.
# Grey hint text behind the cursor (same style as zsh-autosuggestions).
_ollama_postdisplay() {
    # shellcheck disable=SC2034 # POSTDISPLAY/region_highlight are read by zle
    POSTDISPLAY="$1"
    # shellcheck disable=SC2034,SC2206 # zsh array filter: drop our previous highlight
    region_highlight=(${region_highlight:#*memo=ollama})
    [[ -n "$1" ]] && region_highlight+=("$#BUFFER $(($#BUFFER + $#POSTDISPLAY)) fg=#6272a4 memo=ollama")
}

# Cancel a pending async zsh-autosuggestions request — its late response would
# overwrite (or clear) POSTDISPLAY. Mirrors the plugin's own cancel logic (v0.7.x).
_ollama_cancel_autosuggest() {
    local fd="${_ZSH_AUTOSUGGEST_ASYNC_FD-}"
    [[ -n "$fd" ]] || return 0
    zle -F "$fd" 2>/dev/null
    exec {fd}<&- 2>/dev/null
    _ZSH_AUTOSUGGEST_ASYNC_FD=
    [[ -n "${_ZSH_AUTOSUGGEST_CHILD_PID-}" ]] && kill -TERM "$_ZSH_AUTOSUGGEST_CHILD_PID" 2>/dev/null
    return 0
}

# ollama-ai runs as a separate bash process and cannot see this shell's aliases and functions.
# Write them where it can read them, so `ll`, `lg` or your own functions get explained correctly.
# Only functions from ~/.zsh/ and ~/.zshrc* are kept (not oh-my-zsh's hundreds of internals).
_ollama_ai_refresh_context() {
    zmodload zsh/parameter 2>/dev/null
    local dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/ollama-context" f
    mkdir -p "$dir" || return 0
    alias >"$dir/aliases.$$"
    # shellcheck disable=SC2296,SC2154 # zsh-only: functions_source comes from zsh/parameter
    for f in ${(k)functions_source}; do
        [[ "$f" == _* ]] && continue
        [[ "${functions_source[$f]}" == $HOME/.zsh/* || "${functions_source[$f]}" == $HOME/.zshrc* ]] || continue
        functions -- "$f"
    done >"$dir/functions.$$"
    mv -f "$dir/aliases.$$" "$dir/aliases"
    mv -f "$dir/functions.$$" "$dir/functions"
}

# After the first prompt (so .zshrc.local and mise are loaded): refresh once, in the background.
_ollama_ai_context_once() {
    # nomonitor: no "[1] 12345" job notice when the shell starts.
    setopt localoptions nomonitor
    add-zsh-hook -d precmd _ollama_ai_context_once
    (_ollama_ai_refresh_context) & disown
}
if [[ -o interactive ]]; then
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _ollama_ai_context_once
fi

_ollama_explain_widget() {
    [[ -n "$BUFFER" ]] || return
    _ollama_ai_refresh_context
    _ollama_cancel_autosuggest
    # No "[1] 12345" job notices inside zle.
    setopt localoptions nomonitor nonotify
    local out_file pid key model i=0
    local -a spinner=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)

    if ! model="$(ollama-ai active 2>/dev/null)"; then
        _ollama_postdisplay "  ⚠ no local AI switched on (Ctrl+, to pick one)"
        return
    fi

    out_file="$(mktemp)"
    ollama-ai explain -q "$BUFFER" >"$out_file" 2>/dev/null &
    pid=$!
    # Not a shell job: keeps starship's job indicator and "done" notices away.
    disown
    while kill -0 "$pid" 2>/dev/null; do
        _ollama_postdisplay "  ${spinner[i % ${#spinner[@]} + 1]} explaining…"
        zle -M "$(ollama-ai bubble --plain "$COLUMNS" "$model" <"$out_file")"
        zle -R
        i=$((i + 1))
        if read -r -t 0.1 -k key; then
            kill "$pid" 2>/dev/null
            rm -f "$out_file"
            _ollama_postdisplay ""
            zle -M ""
            zle -U "$key"
            return
        fi
    done
    _ollama_postdisplay ""
    if [[ -s "$out_file" ]]; then
        # Final answer: colored box printed above the next prompt, so it stays in the scrollback
        # (zle -M can only show uncolored, ephemeral text). zle -I moves below the command line;
        # zle -R then redraws the prompt underneath. Not "zle reset-prompt": it moves the cursor up
        # by the prompt height first and would overwrite the last rows of the box.
        zle -I
        ollama-ai bubble "$COLUMNS" "$model" <"$out_file"
        zle -R
    else
        zle -M "⚠ no answer from $model"
    fi
    rm -f "$out_file"
}

# Ctrl+O — start opencode in the current directory. Runs as a normal command line
# (wrapper + history); a half-typed line is parked and comes back afterwards.
_opencode_widget() {
    [[ -n "$BUFFER" ]] && zle push-line
    # shellcheck disable=SC2034 # BUFFER is read by zle accept-line
    BUFFER="opencode"
    zle accept-line
}

if [[ -o interactive && -t 0 && -o zle ]]; then
    zle -N _opencode_widget
    bindkey '^O' _opencode_widget
    zle -N _ollama_explain_widget
    bindkey '\e[46;5u' _ollama_explain_widget
    # Not wrapped by zsh-autosuggestions: it would restore its suggestion over our POSTDISPLAY.
    # shellcheck disable=SC2034 # read by zsh-autosuggestions
    ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(_ollama_explain_widget _ollama_menu_widget)
fi
