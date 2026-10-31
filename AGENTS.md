# dotfiles

Public GNU Stow dotfiles for Ubuntu (native and WSL2): zsh + oh-my-zsh, tmux, starship, mise,
git, Neovim, lazygit, opencode, plus a local AI layer (Ollama on the Windows host).

## Layout
- Top-level directories `git/ zsh/ tmux/ starship/ mise/ nvim/ opencode/ lazygit/ claude/` are
  Stow packages mirroring `~/...`. Stow with `stow --no-folding -d ~/dotfiles -t ~ <package>`;
  new files or packages need a re-stow (`make stow`).
- Not stowed: `docs/`, `test/`, `ai/`, `install.sh`, `windows-terminal/` (synced with
  `zsh/bin/wt-settings`) and the tooling files in the root.
- `zsh/bin/*` ends up in `~/bin`; `zsh/.zsh/*.zsh` are the modules `zsh/.zshrc` loads.

## Commands
- `make lint` (shellcheck, shfmt, gitleaks on every file), `make secrets`, `make rules`,
  `make test` (Docker end-to-end install, see `./test/run.sh help`), `make hooks`.

## Rules
- Detailed, path-scoped rules are in `ai/rules/*.md`. opencode loads them through
  `opencode.json`; Claude Code and Cursor use generated copies in `.claude/rules/` and
  `.cursor/rules/`. Personal rules for every project: `ai/global/AGENTS.md`.
- Edit the sources, then run `make rules`. Never edit generated files; a pre-commit hook and CI
  fail when they drift.

## Always
- Never commit secrets or private data (`*.local`, `.env`, `.ssh`, the opencode memory in
  `opencode/.config/opencode/memory/`). `make secrets` must stay clean.
- Bash scripts pass `shellcheck -x` and `shfmt`. Pin tool versions (mise, refs in `install.sh`).
  Comments in English. Keep diffs minimal and match the surrounding style.
