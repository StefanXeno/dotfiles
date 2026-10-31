---
description: Local AI layer (ollama-ai, ollama-menu, Ctrl+R / Ctrl+. widgets, tmux and prompt segments) - conventions and pitfalls
paths:
  - "zsh/bin/ollama-*"
  - "zsh/bin/tmux-ai-status"
  - "zsh/bin/claude-usage"
  - "zsh/.zsh/ollama.zsh"
  - "zsh/.zsh/fzf.zsh"
  - "starship/**"
  - "tmux/**"
---
<!-- Generated from ai/rules/local-ai.md by ai/sync - edit the source, not this file. -->

# Local AI Layer

- **Degrade silently.** No Ollama, no loaded model, no `jq`, no `ip`, no opencode, no Claude cache:
  nothing may print errors or stall the prompt. Anything that runs per prompt, status refresh or keystroke
  must go through `active_model` in `ollama-ai`: it uses a 0.15 s connect timeout and remembers a dead
  Ollama for 5 s (`~/.cache/dotfiles/ollama-down`), because a Windows host that drops packets costs the
  full timeout on every call. Do not add bare `curl` calls to the hot paths.
- **opencode wrapper:** it starts Ollama only for an `ollama/...` model, and `ollama-menu up` reports when
  Ollama is not installed on Windows instead of waiting 30 s.
- **Shell state is invisible to bash scripts.** `ollama.zsh` writes aliases and own functions to
  `~/.cache/dotfiles/ollama-context/`; `ollama-ai` reads them to explain `ll`, `lg`, `k`, ...
- **mise tools are on PATH only after `mise activate`** (end of `.zshrc`). Never guard a definition with
  `command -v tool` at load time; define a function that checks when it is called.
- **zle widgets** print above the prompt with `zle -I`, the output, then `zle -R`. `zle reset-prompt`
  moves the cursor up by the prompt height first and overwrites the last output rows. Background jobs
  started from a hook need `setopt localoptions nomonitor`, otherwise `[1] 12345` shows up.
- **tmux:** status additions go after the TPM `run` line (the theme builds `status-right` then).
  `run-shell` expands formats itself, so write `##(cmd)` for a literal `#(cmd)`. New scripts in `zsh/bin`
  need a re-stow before `~/bin/<name>` exists. `tmux-ai-status` prints nothing when there is nothing to show.
- **Prompt:** the starship modules `custom.claude` / `custom.ollama` use `when = '[ -z "${TMUX:-}" ]'`; inside
  tmux the status bar shows the same values.
- **Answer cache:** everything the answer depends on belongs into the cache key; bump `PROMPT_VERSION` in
  `ollama-ai` when the prompt or the output format changes.
- **Card renderer:** it reads the whole answer first (columns are aligned across rows), moves `⚠` lines below
  the summary and drops "this is safe" warnings; width is counted in terminal columns (`text_width`).
- **fzf preview:** the size comes from `FZF_LINES` / `FZF_PREVIEW_LINES` (already without margin and border);
  `refresh-preview` on `resize` re-renders it after a tmux split.
