---
description: Cheatsheet markdown format, parser contract, and cs/Ctrl+H integration
paths:
  - "docs/cheatsheets/**"
  - "zsh/.zsh/cheatsheets.zsh"
  - "zsh/bin/cs-parse-cheatsheets.awk"
---
<!-- Generated from ai/rules/cheatsheets.md by ai/sync - edit the source, not this file. -->

# Cheatsheets System

## Flow

```
docs/cheatsheets/*.md → cs-parse-cheatsheets.awk → TSV cache → fzf (cs / Ctrl+H)
```

Cheatsheets are **not** stowed — they read from `$DOTFILES_DIR/docs/cheatsheets`.

## Markdown table formats

Parser supports these schemas (see existing files for examples):

| Schema | Columns |
|---|---|
| Aliases | `Alias \| Command \| What it does` |
| Actions | `Action \| Keys \| What it does` |
| Tasks | `Task \| Command \| What it does` |

- Wrap shell commands in backticks; parser masks pipes inside backticks.
- Code blocks (` ```bash `) are also parsed — one command per line where possible.

## When adding commands

1. Add row to the matching `docs/cheatsheets/<topic>.md`.
2. If it's a new alias/helper, also update `zsh/.zsh/aliases.zsh` or the relevant module.
3. Optionally extend `docs/<topic>.md` for narrative docs.

## Parser changes

`zsh/bin/cs-parse-cheatsheets.awk` is the contract — changing it requires verifying output row count (Docker verify or manual `awk -f …`).

## Safety

Destructive commands (`git clean -fd`, `rm -rf`, etc.) need a clear "What it does" column — users can run them via `cs`.
