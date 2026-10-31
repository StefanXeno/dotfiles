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
for _zsh_module in options fzf aliases tmux completions k9s-functions cheatsheets; do
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

# kxd — kubeconfig switcher. Defines the `kxd` shell function (exports KUBECONFIG
# after switches) and reapplies the last selection from ~/.kxd.
# Must run after mise activate so the binary is on PATH.
if command -v kxd &>/dev/null; then
    eval "$(kxd init zsh)"
fi

# fzf shell integration (fzf 0.48+) — Ctrl+R, Ctrl+T, Alt+C (Ctrl+K → kxd; Ctrl+H → cheatsheets.zsh)
# Requires a TTY — skip in scripts/CI (avoids "can't change option: zle").
if [[ -o interactive && -t 0 ]] && command -v fzf &>/dev/null; then
    eval "$(fzf --zsh)"
fi

# Ctrl+K — fzf kubeconfig picker (replaces default kill-line).
# Uses fzf instead of `kxd file switch` (promptui): promptui steals/fails under zle,
# and fzf reuses the Dracula theme from FZF_DEFAULT_OPTS (same as Ctrl+R/T).
# Preview reads contexts/namespaces from the file locally (no API call).
# shellcheck disable=SC1073,SC1072,SC1009 # zle widget bindings are zsh-only
if [[ -o interactive && -t 0 && -o zle ]] \
    && command -v kxd &>/dev/null \
    && command -v fzf &>/dev/null; then
    _kxd_file_switch_widget() {
        local selected
        selected="$(
            command kxd file list \
                | FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS-}" fzf \
                    --prompt='☸️ Kubeconfig: ' \
                    --header='🔍 Switch kubeconfig' \
                    --preview '
                        name={}
                        if [ "$name" = unset ]; then
                            printf "%s\n" "KUBECONFIG will be unset"
                            exit 0
                        fi
                        if [ "$name" = default ]; then
                            kc="$HOME/.kube/config"
                        else
                            kc="$HOME/.kube/$name"
                        fi
                        printf "File: %s\n\n" "$kc"
                        if [ ! -f "$kc" ]; then
                            printf "%s\n" "(file not found)"
                            exit 0
                        fi
                        if ! command -v kubectl >/dev/null 2>&1; then
                            printf "%s\n" "kubectl not found"
                            exit 0
                        fi
                        # Contexts + default namespace from the file (no AUTHINFO, no API call)
                        cur=$(kubectl --kubeconfig "$kc" config current-context 2>/dev/null || true)
                        kubectl --kubeconfig "$kc" config view -o jsonpath="{range .contexts[*]}{.name}{\"\t\"}{.context.cluster}{\"\t\"}{.context.namespace}{\"\n\"}{end}" 2>/dev/null \
                            | awk -v cur="$cur" -F "\t" "
                                BEGIN { printf \"%-2s %-36s %-36s %s\n\", \"\", \"NAME\", \"CLUSTER\", \"NAMESPACE\" }
                                {
                                    mark = (\$1 == cur) ? \"*\" : \" \"
                                    ns = (\$3 == \"\") ? \"-\" : \$3
                                    printf \"%-2s %-36s %-36s %s\n\", mark, \$1, \$2, ns
                                }
                            " \
                            || printf "%s\n" "(unreadable or invalid kubeconfig)"
                    ' \
                    --preview-window 'right:55%:wrap' \
                    --bind 'ctrl-/:toggle-preview' \
                    --bind 'focus:preview-top'
        )" || {
            zle reset-prompt
            return
        }
        [[ -n "$selected" ]] || {
            zle reset-prompt
            return
        }
        # Shell function (from kxd init) writes ~/.kxd and exports KUBECONFIG
        kxd "$selected"
        zle reset-prompt
    }
    zle -N _kxd_file_switch_widget
    bindkey '^K' _kxd_file_switch_widget
fi

# ============================================================
# PROMPT
# ============================================================

# Initialize Starship after mise so the [mise] module sees active tool versions.
eval "$(starship init zsh)"
