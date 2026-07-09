#!/usr/bin/env bash

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

log()     { echo -e "\033[0;32m[✓]\033[0m $*"; }
warn()    { echo -e "\033[0;33m[!]\033[0m $*"; }
err()     { echo -e "\033[0;31m[✗]\033[0m $*" >&2; }
info()    { echo -e "\033[0;34m[→]\033[0m $*"; }
section() { echo -e "\n\033[1;35m══ $* ══\033[0m"; }

# ── State checks ─────────────────────────────────────────────────────────────

# Check if the container is currently running (has state=running, not just created/stopped)
container_is_running() {
    docker ps \
        --filter "name=^dotfiles-test$" \
        --filter "status=running" \
        --quiet 2>/dev/null | grep -q .
}

# Check if our image has been built at all
image_exists() {
    docker image inspect dotfiles-test:local &>/dev/null
}

# ── Actions ──────────────────────────────────────────────────────────────────

# Build image + start container (used only by 'install').
# This is the only command that is allowed to rebuild the image.
build_and_start() {
    info "Building image and starting container..."
    if ! docker compose -f "$COMPOSE_FILE" up -d --build; then
        err "Failed to build or start container."
        err "Run './test/run.sh reset' to wipe everything and try again."
        return 1
    fi
    log "Container is up."
}

# Start the container WITHOUT rebuilding (used by 'shell' and 'bash').
# Preserves all state from the previous install run.
start_without_rebuild() {
    if container_is_running; then
        # Already running — nothing to do
        return 0
    fi

    if ! image_exists; then
        err "No image found — container has never been built."
        warn "Run './test/run.sh install' first."
        return 1
    fi

    info "Container is stopped — restarting (without rebuild)..."
    # 'up -d' without '--build': reuses the existing image, keeps filesystem state
    if ! docker compose -f "$COMPOSE_FILE" up -d; then
        err "Failed to start container."
        return 1
    fi

    log "Container restarted."
}

# ── Commands ─────────────────────────────────────────────────────────────────

case "${1:-help}" in

    install)
        # Full end-to-end test:
        #   1. Build fresh image
        #   2. Start container
        #   3. Run install.sh inside it
        #   4. On failure: auto-drop into bash for debugging
        build_and_start || exit 1

        section "Running install.sh"

        docker compose -f "$COMPOSE_FILE" exec dotfiles-test \
            bash /home/stefan/dotfiles/install.sh
        install_exit_code=$?

        echo ""
        if [[ $install_exit_code -eq 0 ]]; then
            log "install.sh completed successfully!"
            echo ""
            echo "  Verify your setup:  ./test/run.sh shell"
            echo "  Debug with bash:    ./test/run.sh bash"
            echo ""
        else
            err "install.sh failed with exit code: $install_exit_code"
            warn "Dropping into bash for debugging..."
            echo ""
            warn "Useful commands:"
            warn "  bash ~/dotfiles/install.sh   → retry install manually"
            warn "  apt list --installed          → check installed packages"
            warn "  cat /tmp/install.log          → if you piped output there"
            echo ""
            docker compose -f "$COMPOSE_FILE" exec dotfiles-test bash
        fi
        ;;

    shell)
        # Drop into zsh — uses the EXISTING container, never rebuilds.
        # The container must have been installed first via './test/run.sh install'.
        start_without_rebuild || exit 1

        info "Dropping into zsh..."
        if ! docker compose -f "$COMPOSE_FILE" exec dotfiles-test zsh; then
            err "Could not start zsh."
            warn "Has install.sh been run? Try './test/run.sh install' first."
            warn "Or use './test/run.sh bash' to debug."
        fi
        ;;

    bash)
        # Drop into bash — uses the EXISTING container, never rebuilds.
        # Works both before and after install (bash is always available).
        start_without_rebuild || exit 1

        info "Dropping into bash..."
        docker compose -f "$COMPOSE_FILE" exec dotfiles-test bash
        ;;

    logs)
        info "Container logs (last 50 lines):"
        docker compose -f "$COMPOSE_FILE" logs --tail=50
        ;;

    rebuild)
        # Force a completely clean build — no cached layers.
        # Use this when Dockerfile changes aren't being picked up.
        info "Stopping container..."
        docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans

        info "Rebuilding with --no-cache --pull..."
        docker compose -f "$COMPOSE_FILE" build --no-cache --pull
        log "Done. Run './test/run.sh install' to test."
        ;;

    reset)
        # Destroy everything: container, volumes AND the built image.
        # '--rmi all' removes all images tied to this compose project —
        # no need to guess the image name.
        info "Destroying container and image..."
        if docker compose -f "$COMPOSE_FILE" down --volumes --remove-orphans --rmi all; then
            log "Done."
        else
            warn "Nothing to remove (already clean)."
        fi

        docker builder prune -f --filter "until=1h" 2>/dev/null || true
        log "Clean slate. Run './test/run.sh install' to start fresh."
        ;;

    help|*)
        echo ""
        echo "Usage: ./test/run.sh <command>"
        echo ""
        echo "Commands:"
        echo "  install   Build image + run install.sh (always full rebuild)"
        echo "  shell     Exec into running container as zsh  (no rebuild!)"
        echo "  bash      Exec into running container as bash (no rebuild!)"
        echo "  logs      Show last 50 lines of container output"
        echo "  rebuild   Force rebuild with --no-cache (when Dockerfile changed)"
        echo "  reset     Destroy container + image for a clean slate"
        echo ""
        echo "Typical workflow:"
        echo "  1. ./test/run.sh install   ← build + install everything"
        echo "  2. ./test/run.sh shell     ← verify the result in zsh"
        echo "  3. ./test/run.sh reset     ← nuke it all, start fresh"
        echo ""
        ;;
esac