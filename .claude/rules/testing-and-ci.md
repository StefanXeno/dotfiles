---
description: Docker E2E tests, shellcheck CI, and verification conventions
paths:
  - "test/**"
  - ".github/**/*"
---
<!-- Generated from ai/rules/testing-and-ci.md by ai/sync - edit the source, not this file. -->

# Testing and CI

## Shellcheck (must pass)

- All `*.sh` files: `shellcheck -x`
- Bash-compatible zsh modules: `shellcheck -x -s bash zsh/.zsh/{aliases,cheatsheets,fzf,k9s-functions,tmux}.zsh`
- The `zsh/bin/*` scripts and `ai/sync` (no `.sh` extension — listed explicitly in the workflow)
- Also in CI: `gitleaks` on the full history (pinned release, checksum verified) and `ai/sync --check`. Locally the same checks run as pre-commit hooks (`make hooks`, `make lint`).

## Docker E2E (`./test/run.sh install`)

The repo is mounted read-only; `run.sh` copies it (rsync, without the private opencode memory) to `~/dotfiles` as the container user (`./test/run.sh sync` does only that). Do not bind-mount it writable: in rootless Docker the host user is root inside the container, so the container user could not chmod, run lazy.nvim or use git there. `install` needs a TTY; without one run the same steps with `docker compose exec -T`.

Post-install verification runs inside the container:

- `verify_tmux` — config syntax via `tmux list-keys`
- `verify_dotfiles_stack` — starship, mise, fzf, direnv, awk parser rows > 0, zsh helpers (`cs`, `cso`, `ta`, `tn`, `tl`)

Run after changes to `install.sh`, `test/run.sh`, or cheatsheet parser.

## In-container script style

Pass bash to `_docker_exec` via **quoted heredocs** — not single-quoted strings (shellcheck SC2016):

```bash
_docker_exec "$(cat <<'VERIFY'
set -euo pipefail
# variables expand inside container, not on host
VERIFY
)"
```

Inside verify scripts: bootstrap mise with `export PATH="$HOME/.local/bin:$PATH"` + `eval "$(mise activate bash)"`.

## GitHub Actions

Pin third-party actions by **commit SHA**, not floating tags.
