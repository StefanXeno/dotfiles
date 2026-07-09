#!/usr/bin/env bash
# ============================================================
# Dotfiles Install Script
# Supports: Ubuntu 22.04+ (native & WSL2)
# Usage:    bash ~/dotfiles/install.sh
# ============================================================

set -euo pipefail
IFS=$'\n\t'
export PATH="$HOME/.local/bin:$PATH"

# ---------- Constants ----------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# OMZ custom plugins to clone (name → git URL)
declare -A OMZ_CUSTOM_PLUGINS=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
    ["autoupdate"]="https://github.com/TamCore/autoupdate-oh-my-zsh-plugins"
)

# Pin plugin versions for reproducible installs (empty = latest)
declare -A OMZ_CUSTOM_PLUGIN_REFS=(
    ["zsh-autosuggestions"]="v0.7.1"
    ["zsh-syntax-highlighting"]="0.8.0"
)

# Stow packages to install (= top-level directories in this repo)
STOW_PACKAGES=(git zsh tmux starship mise)

MISE_CORE_TOOLS=(
    fzf       # Used in .zshrc for Ctrl+R / Ctrl+T / Alt+C key bindings
    direnv    # Used in .zshrc: eval "$(direnv hook zsh)"
    usage     # Required by mise for shell completions
)

# ---------- Helpers ----------

log()     { echo -e "\033[0;32m[✓]\033[0m $*"; }
warn()    { echo -e "\033[0;33m[!]\033[0m $*"; }
err()     { echo -e "\033[0;31m[✗]\033[0m $*" >&2; exit 1; }
info()    { echo -e "\033[0;34m[→]\033[0m $*"; }
section() { echo -e "\n\033[1;35m══ $* ══\033[0m"; }

is_wsl()          { grep -qi microsoft /proc/version 2>/dev/null; }
# Detect if running inside a Docker container.
# Docker always creates this file in the root filesystem.
is_docker() { [[ -f /.dockerenv ]]; }
command_exists()  { command -v "$1" &>/dev/null; }

# Backup a file/dir if it exists and is not already a symlink
backup_if_exists() {
    local target="$1"
    if [[ -e "$target" && ! -L "$target" ]]; then
        mkdir -p "$BACKUP_DIR"
        warn "Backing up: $target → $BACKUP_DIR/"
        cp -r "$target" "$BACKUP_DIR/"
        rm -rf "$target"
    fi
}

# Backup all files that a stow package would try to create symlinks for.
# This prevents stow from failing with "existing target" errors.
backup_stow_conflicts() {
    local package="$1"
    local package_dir="$DOTFILES_DIR/$package"

    # Find all files (not dirs) in the package and calculate their target paths
    while IFS= read -r src_file; do
        local rel_path="${src_file#"$package_dir/"}"
        local target="$HOME/$rel_path"
        backup_if_exists "$target"
    done < <(find "$package_dir" -type f)
}

# ---------- 1. APT Packages ----------

install_apt_packages() {
    section "APT Packages"

    sudo apt-get update -qq

    local packages=(
        git
        curl
        wget
        stow
        zsh
        tmux
        fd-find       # 'fd' file finder (available as 'fdfind' on Ubuntu)
        bat           # Better 'cat' (available as 'batcat' on Ubuntu)
        tree          # Directory tree viewer (used in fzf preview)
        xclip         # Clipboard tool (for non-WSL systems)
        python3-venv  # Required by mise pipx backends (azure-cli, pipx tool)
        python3-pygments  # Syntax highlighting for the OMZ colorize plugin
        source-highlight  # Syntax highlighting for 'less' (LESSOPEN)
        sl            # Important. Very important.
        unzip
        build-essential
    )

    sudo apt-get install -y "${packages[@]}"
    log "APT packages installed."
}

# ---------- 2. Oh-My-Zsh ----------

install_omz() {
    section "Oh-My-Zsh"

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh-My-Zsh already installed — skipping."
        return
    fi

    info "Installing Oh-My-Zsh..."

    # The OMZ installer internally calls 'chsh' to change the default shell.
    # In Docker containers, chsh can fail because PAM is not fully configured.
    # We use '|| true' to treat a non-zero exit as a warning, not a fatal error.
    # The shell change is handled separately by set_default_shell() anyway.
    KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended \
        || warn "OMZ installer exited non-zero (likely a chsh issue in Docker — this is fine)"

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        log "Oh-My-Zsh installed."
    else
        err "Oh-My-Zsh directory not found after install — something went wrong."
    fi
}

# ---------- 3. OMZ Custom Plugins ----------

install_omz_plugins() {
    section "OMZ Custom Plugins"

    local custom_plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    mkdir -p "$custom_plugins_dir"

    for plugin_name in "${!OMZ_CUSTOM_PLUGINS[@]}"; do
        local plugin_url="${OMZ_CUSTOM_PLUGINS[$plugin_name]}"
        local plugin_dir="$custom_plugins_dir/$plugin_name"

        local plugin_ref="${OMZ_CUSTOM_PLUGIN_REFS[$plugin_name]:-}"

        if [[ -d "$plugin_dir" ]]; then
            info "Plugin '$plugin_name' already installed — updating..."
            git -C "$plugin_dir" fetch --quiet origin
            if [[ -n "$plugin_ref" ]]; then
                git -C "$plugin_dir" checkout --quiet "$plugin_ref"
            else
                git -C "$plugin_dir" pull --quiet
            fi
        else
            info "Installing plugin: $plugin_name"
            if [[ -n "$plugin_ref" ]]; then
                git clone --depth=1 --branch "$plugin_ref" "$plugin_url" "$plugin_dir"
            else
                git clone --depth=1 "$plugin_url" "$plugin_dir"
            fi
        fi
    done

    log "OMZ custom plugins ready."
}

# ---------- 4. mise ----------

install_mise() {
    section "mise"

    # ── Install mise binary ──────────────────────────────────────────────────
    if command_exists mise; then
        log "mise already installed — skipping."
    else
        info "Installing mise..."
        curl -fsSL https://mise.run | sh
        log "mise installed."
    fi

    # ── Core tools — fatal if any of these fail ──────────────────────────────
    # These are required for the shell to function (fzf key bindings, direnv hook, etc.)
    info "Installing core tools..."
    for tool in "${MISE_CORE_TOOLS[@]}"; do
        info "  → $tool"
        if ! mise install "$tool"; then
            err "Failed to install core tool: $tool — cannot continue."
        fi
    done
    log "Core tools installed."

    # ── All remaining tools — non-fatal ──────────────────────────────────────
    # Runs 'mise install' for everything defined in config.toml.
    # Individual failures (e.g. azure-cli) are logged but don't stop the install.
    info "Installing all remaining tools..."
    if mise install 2>/tmp/mise_install.err; then
        log "All tools installed."
    else
        warn "Some tools failed to install — this is non-fatal."
        warn "Failed output:"
        # Indent the mise error output for readability
        sed 's/^/    /' /tmp/mise_install.err | grep -i "error" || true
        warn "Re-run manually later: mise install <toolname>"
    fi
}

# ---------- 5. Starship ----------

install_starship() {
    section "Starship"

    if command_exists starship; then
        log "Starship already installed — skipping."
        return
    fi

    info "Installing Starship..."
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
    log "Starship installed."
}

# ---------- 6. TPM (Tmux Plugin Manager) ----------

install_tpm() {
    section "TPM (Tmux Plugin Manager)"

    local tpm_dir="$HOME/.tmux/plugins/tpm"

    if [[ -d "$tpm_dir" ]]; then
        log "TPM already installed — pulling latest..."
        git -C "$tpm_dir" pull --quiet
    else
        info "Installing TPM..."
        git clone --depth=1 https://github.com/tmux-plugins/tpm "$tpm_dir"
        log "TPM installed."
    fi

    info "Remember to install tmux plugins after first launch: prefix + I"
}

# ---------- 6b. WSL Windows Toast Notifications ----------

install_wsl_notify() {
    if ! is_wsl; then
        return
    fi

    section "WSL Notifications (wsl-notify-send)"

    local dest="$HOME/bin/wsl-notify-send.exe"
    local version="v0.1.871612270"
    local arch zip_url tmp_zip answer

    if [[ -x "$dest" ]]; then
        log "wsl-notify-send.exe already installed — skipping."
        return
    fi

    # Docker CI and non-interactive shells cannot prompt — skip quietly
    if is_docker || [[ ! -t 0 ]]; then
        info "Non-interactive install — skipping optional wsl-notify-send."
        info "Re-run install.sh in an interactive WSL session to opt in."
        return
    fi

    echo ""
    echo "  wsl-notify-send is an optional Windows .exe that lets tools like"
    echo "  tmux-notify show native Windows toast notifications from WSL."
    echo "  The ~/bin/notify-send wrapper uses it when present."
    echo ""
    warn "  On managed PCs, Group Policy / AppLocker may block unknown executables."
    warn "  If blocked, Windows often reports this as 'Invalid argument' from WSL."
    echo ""
    read -r -p "  Install wsl-notify-send.exe to ~/bin/? [y/N] " answer
    if [[ ! "$answer" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        info "Skipped wsl-notify-send (install anytime by re-running install.sh)."
        return
    fi

    case "$(uname -m)" in
        x86_64)  arch="amd64" ;;
        i686|i386) arch="386" ;;
        *)
            warn "No wsl-notify-send build for $(uname -m) — install manually if needed."
            return
            ;;
    esac

    zip_url="https://github.com/stuartleeks/wsl-notify-send/releases/download/${version}/wsl-notify-send_windows_${arch}.zip"
    tmp_zip="$(mktemp)"

    info "Downloading wsl-notify-send ${version} (${arch})..."
    if ! curl -fsSL "$zip_url" -o "$tmp_zip"; then
        warn "Failed to download wsl-notify-send — tmux-notify toasts will not work on WSL."
        warn "Manual install: https://github.com/stuartleeks/wsl-notify-send/releases"
        rm -f "$tmp_zip"
        return
    fi

    unzip -qo "$tmp_zip" -d "$HOME/bin"
    rm -f "$tmp_zip"
    chmod +x "$dest"

    log "wsl-notify-send installed to ~/bin/"
    info "Test: notify-send \"Hello\" \"from WSL\""
}

# ---------- 7. Stow Dotfiles ----------

stow_dotfiles() {
    section "Stow Dotfiles"

    mkdir -p "$HOME/bin"
    if [[ -f "$DOTFILES_DIR/zsh/bin/notify-send" ]]; then
        chmod +x "$DOTFILES_DIR/zsh/bin/notify-send"
    fi

    for package in "${STOW_PACKAGES[@]}"; do
        info "Stowing: $package"

        # Back up any conflicting files before stowing
        backup_stow_conflicts "$package"

        # --no-folding: always symlink individual files, never entire directories.
        #               Critical for ~/.config/ since other apps also write there.
        # -d: source directory (our dotfiles repo)
        # -t: target directory (home directory)
        stow --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$package"

        log "Stowed: $package"
    done

    if [[ -d "$BACKUP_DIR" ]]; then
        warn "Some files were backed up to: $BACKUP_DIR"
        warn "Review them and delete the backup dir when you're done."
    fi
}

# ---------- 8. Create Local Template Files ----------

create_local_templates() {
    section "Local Config Templates"

    # .zshrc.local — private shell config
    if [[ ! -f "$HOME/.zshrc.local" ]]; then
        info "Creating ~/.zshrc.local template..."
        cat > "$HOME/.zshrc.local" << 'EOF'
# ~/.zshrc.local
# Machine-specific and private shell config.
# This file is NOT tracked in git.

# --- Identity ---
# export WORK_EMAIL="you@company.com"

# --- Work aliases ---
# alias vpn="sudo openconnect vpn.company.com"

# --- API Keys / Secrets ---
# export SOME_API_KEY=""

# --- Proxy (if needed) ---
# export HTTP_PROXY=""
# export HTTPS_PROXY=""
# export NO_PROXY="localhost,127.0.0.1"
EOF
        log "Created ${HOME}/.zshrc.local"
    else
        log "${HOME}/.zshrc.local already exists — skipping."
    fi

    # .gitconfig.local — private git config
    if [[ ! -f "$HOME/.gitconfig.local" ]]; then
        info "Creating ~/.gitconfig.local template..."
        cat > "$HOME/.gitconfig.local" << 'EOF'
# ~/.gitconfig.local
# Machine-specific git config.
# This file is NOT tracked in git.
#
# REQUIRED: Fill in your details before committing anything!

[user]
    name  = Stefan
    email = your@email.com
    # Path to the PUBLIC KEY (.pub) of this machine's signing key.
    # See README.md for how to generate a per-machine SSH signing key.
    signingkey = ~/.ssh/id_ed25519_signing_MACHINENAME.pub
EOF
        log "Created ${HOME}/.gitconfig.local"
    else
        log "${HOME}/.gitconfig.local already exists — skipping."
    fi

    # ~/.ssh/allowed_signers — required for local signature verification
    if [[ ! -f "$HOME/.ssh/allowed_signers" ]]; then
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        touch "$HOME/.ssh/allowed_signers"
        chmod 600 "$HOME/.ssh/allowed_signers"
        info "Created ~/.ssh/allowed_signers (empty — add your public keys here)"
        info "Format: 'your@email.com ssh-ed25519 AAAA... key-comment'"
    fi
}

# ---------- 9. Default Shell ----------

set_default_shell() {
    section "Default Shell"

    # 'chsh' doesn't make sense in a Docker container:
    #   1. The shell change wouldn't persist after 'docker exec' ends anyway
    #   2. chsh requires PAM, which isn't fully set up in containers
    # Instead, we just verify zsh is installed and tell the user.
    if is_docker; then
        if command_exists zsh; then
            log "Running in Docker — skipping chsh."
            info "To get a zsh session, run: ./test/run.sh shell"
        else
            err "zsh not found — something went wrong with APT install."
        fi
        return
    fi

    local zsh_path
    zsh_path="$(which zsh)"

    if [[ "$SHELL" == "$zsh_path" ]]; then
        log "zsh is already the default shell."
        return
    fi

    info "Setting zsh as default shell..."
    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi
    chsh -s "$zsh_path"
    log "Default shell set to zsh. Takes effect on next login."
}

# ---------- Main ----------

main() {
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║      Dotfiles Install Script         ║"
    if is_docker; then
    echo "║      Environment: Docker             ║"
    elif is_wsl; then
    echo "║      Environment: WSL2               ║"
    else
    echo "║      Environment: Native Linux       ║"
    fi
    echo "╚══════════════════════════════════════╝"
    echo ""

    install_apt_packages
    install_omz
    install_omz_plugins

    # stow_dotfiles MUST come before install_mise!
    # mise needs ~/.config/mise/config.toml to know which tools to install.
    # That file only exists after stow creates the symlink.
    stow_dotfiles

    # Now mise can find its config and install all tools (including fzf)
    install_mise
    install_starship
    install_tpm
    install_wsl_notify

    create_local_templates
    set_default_shell

    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║        Install complete! 🎉          ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "Next steps:"
    echo "  1. Fill in ~/.gitconfig.local (email + signing key path)"
    echo "  2. Fill in ~/.zshrc.local (secrets, work aliases, etc.)"
    echo "  3. Generate a signing key: see README.md"
    echo "  4. Start a new shell session: exec zsh"
    echo "  5. Open tmux and install plugins: prefix + I"
    echo ""
}

main "$@"