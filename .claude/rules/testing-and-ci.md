---
description: Docker E2E tests, shellcheck CI, and verification conventions
paths:
  - "test/**"
  - ".github/**/*"
---

# Testing and CI

## Shellcheck (must pass)

- All `*.sh` files: `shellcheck -x`
- Bash-compatible zsh modules: `shellcheck -x -s bash zsh/.zsh/{aliases,cheatsheets,fzf,k9s-functions,tmux}.zsh`
- `zsh/bin/notify-send` (no `.sh` extension — listed explicitly in workflow)

## Docker E2E (`./test/run.sh install`)

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
