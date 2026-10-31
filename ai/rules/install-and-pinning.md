---
description: install.sh conventions, version pinning, and install order
paths:
  - "install.sh"
  - "mise/**/*"
---

# Install Script and Pinning

## Pin everything that affects reproducibility

| What | Where |
|---|---|
| OMZ core | `OMZ_REF` (commit SHA) — shallow `git fetch`, **not** `BRANCH=` in upstream installer |
| OMZ custom plugins | `OMZ_CUSTOM_PLUGIN_REFS` |
| TPM plugins | `TPM_PLUGIN_REFS` |
| mise infra tools, daily-driver CLI tools (rg, eza, delta, lazygit, zoxide, neovim) and repo tools (gitleaks, shellcheck, shfmt, pre-commit) | `mise/.config/mise/config.toml` |

- Pinned refs in `install.sh` carry a `# renovate: datasource=github-tags depName=owner/repo` comment above the entry, so Renovate can bump them.
- Do **not** add the `autoupdate` OMZ plugin — it fights pinned versions.
- `latest` in mise is only for misc tools (`jqp`, `dotenvx`, `qdns`, `pipx`, `s3cmd`).

## Install order (do not reorder lightly)

```
APT → OMZ → OMZ plugins → stow → mise → starship → TPM → (WSL) notifications / Windows Terminal → git hooks → local templates → chsh
```

`stow_dotfiles` **must** run before `install_mise` so `~/.config/mise/config.toml` exists.

## Idempotency and backups

- Skip steps when already installed; log and return early.
- `install.sh` sets `umask 022` and only runs `chmod +x` on scripts that are not executable yet (rootless Docker maps the host user to root, so `chmod` on the mounted repo fails with EPERM).
- `backup_if_exists` preserves paths relative to `$HOME` under `~/.dotfiles_backup_*/`.

## Target environment

Ubuntu 22.04+ (native and WSL2). `curl | sh` (OMZ, mise, Starship) is acceptable here but prefer pinned refs where possible.

## Updating pins

Document bumps in README: re-run `install.sh` or manually `git checkout` the pinned ref in the plugin dir.
