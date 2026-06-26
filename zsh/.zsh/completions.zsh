# Zsh-only module (compdef, unfunction) — not checked by shellcheck; sourced by ~/.zshrc
# Lazy-load heavy tool completions on first tab press (faster shell startup)
# The wrapper unfunctions itself after sourcing, then re-binds compdef to the real handler.

if command -v kubectl &>/dev/null; then
    _kubectl_lazy() {
        unfunction _kubectl_lazy
        source <(kubectl completion zsh)
        compdef _kubectl k
        _kubectl "$@"
    }

    compdef _kubectl_lazy kubectl k
fi

if command -v helm &>/dev/null; then
    _helm_lazy() {
        unfunction _helm_lazy
        source <(helm completion zsh)
        _helm "$@"
    }

    compdef _helm_lazy helm
fi

if command -v docker &>/dev/null; then
    _docker_lazy() {
        unfunction _docker_lazy
        source <(docker completion zsh)
        _docker "$@"
    }

    compdef _docker_lazy docker
fi
