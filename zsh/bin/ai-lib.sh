# shellcheck shell=bash
# shellcheck disable=SC2034 # the P_* variables are read by the scripts that source this file
# Shared AI provider lookup for ai-chooser and ollama-ai. Sourced, never executed.
#
# Providers come from a machine-local file (never committed: it holds endpoints and key names):
#   ~/.config/ai/providers.local.json
#     { "NAME": { "type": "ollama" | "openai", "url": "...", "model": "...",
#                 "key_env": "ENV_VAR_WITH_THE_API_KEY", "trust": "local" | "trusted" | "cloud",
#                 "extra_body": { ... }, "name": "...", "timeout": 600000, "models": { ... } } }
# The built-in provider "ollama" (Ollama on the Windows host) always exists; an entry with the
# same name overrides it (e.g. to point at another Ollama). "extra_body" is merged into every
# OpenAI chat request; "name", "timeout" and "models" are only used for the opencode config.
# The active provider is a single line in ~/.local/state/ai/active.

AI_CONFIG_FILE="${AI_PROVIDERS_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/ai/providers.local.json}"
AI_STATE_DIR="${AI_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/ai}"

# Provider fields set by ai_load.
P_NAME="" P_TYPE="" P_URL="" P_MODEL="" P_KEY_ENV="" P_TRUST="" P_EXTRA="{}"

ai_in_config() {
    [[ -r "$AI_CONFIG_FILE" ]] && jq -e --arg n "$1" 'has($n)' "$AI_CONFIG_FILE" >/dev/null 2>&1
}

# Active provider name. Runs on every keystroke of the autosuggest, so the common case
# (nothing chosen, or "ollama") stays free of subprocesses. A provider that vanished from the
# config falls back to ollama instead of breaking every prompt.
ai_active() {
    local name=""
    [[ -r "$AI_STATE_DIR/active" ]] && name="$(<"$AI_STATE_DIR/active")"
    if [[ -n "$name" && "$name" != ollama ]] && ai_in_config "$name"; then
        printf '%s' "$name"
    else
        printf 'ollama'
    fi
}

# All provider names, "ollama" first.
ai_names() {
    echo ollama
    [[ -r "$AI_CONFIG_FILE" ]] && jq -r 'keys[] | select(. != "ollama")' "$AI_CONFIG_FILE" 2>/dev/null
}

# Load provider NAME (default: the active one) into the P_* variables.
ai_load() {
    P_NAME="${1:-$(ai_active)}"
    P_TYPE=ollama P_URL="" P_MODEL="" P_KEY_ENV="" P_TRUST=local P_EXTRA="{}"
    if ai_in_config "$P_NAME"; then
        # "|" and not a tab: read collapses empty fields between whitespace delimiters.
        IFS='|' read -r P_TYPE P_URL P_MODEL P_KEY_ENV P_TRUST < <(
            jq -r --arg n "$P_NAME" '.[$n]
                | [(.type // "ollama"), (.url // ""), (.model // ""), (.key_env // ""),
                   (.trust // (if (.type // "ollama") == "ollama" then "local" else "cloud" end))]
                | join("|")' "$AI_CONFIG_FILE"
        )
        if [[ "$P_TYPE" == openai ]]; then
            P_EXTRA="$(jq -c --arg n "$P_NAME" '.[$n].extra_body // {}' "$AI_CONFIG_FILE")"
        fi
    elif [[ "$P_NAME" != ollama ]]; then
        return 1
    fi
    if [[ "$P_TYPE" == ollama && -z "$P_URL" ]]; then
        # WSL2 NAT mode: the Windows host is the default gateway (changes after reboots).
        OLLAMA_WIN_HOST="${OLLAMA_WIN_HOST:-$(ip route show default 2>/dev/null | awk '{print $3; exit}')}"
        P_URL="${OLLAMA_URL:-http://${OLLAMA_WIN_HOST}:11434}"
    fi
    P_URL="${P_URL%/}"
}

# The API key of the loaded provider (empty when none is needed or the variable is unset).
ai_key() {
    [[ -n "$P_KEY_ENV" ]] || return 0
    printf '%s' "${!P_KEY_ENV:-}"
}

# True for plain http:// to a host that is not this machine or the Windows host: prompts
# and the API key would cross the network unencrypted.
ai_insecure() {
    local host="${1#http://}"
    [[ "$1" == http://* ]] || return 1
    host="${host%%[/:]*}"
    case "$host" in
        localhost | 127.* | ::1 | "${OLLAMA_WIN_HOST:-}") return 1 ;;
    esac
    return 0
}
