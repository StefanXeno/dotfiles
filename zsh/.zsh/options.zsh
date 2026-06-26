# Zsh-only module (setopt, etc.) — not checked by shellcheck; sourced by ~/.zshrc
# Shell options and environment defaults

HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

setopt NO_BEEP
setopt AUTO_CD
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt INC_APPEND_HISTORY

export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"
export EDITOR="${EDITOR:-vim}"

# Bootstrap PATH for mise/direnv before 'mise activate' wires up shims
export PATH="$HOME/.local/bin:$PATH"

# GPG_TTY is still needed if you use GPG for anything other than git signing
# (e.g. decrypting files, password managers). Remove if you go fully SSH-only.
export GPG_TTY=$(tty)

# less with syntax highlighting (requires source-highlight package)
export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
export LESS=' -R '

# colorize plugin config (requires python3-pygments package)
ZSH_COLORIZE_TOOL=pygmentize
ZSH_COLORIZE_STYLE="colorful"
