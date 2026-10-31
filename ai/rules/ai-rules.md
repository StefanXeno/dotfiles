---
description: How the shared AI rules are organized and kept in sync (ai/, AGENTS.md, generated copies)
paths:
  - "ai/**"
  - "AGENTS.md"
  - "CLAUDE.md"
  - "opencode.json"
  - ".claude/**"
  - ".cursor/**"
  - "claude/**"
  - "opencode/**"
---

# Shared AI Rules

One source feeds Claude Code, Cursor and opencode.

| Source (edit) | Derived (never edit) | Read by |
|---|---|---|
| `ai/rules/*.md` | `.claude/rules/*.md` | Claude Code (path-scoped via `paths`) |
| | `.cursor/rules/*.mdc` | Cursor (`globs` + `alwaysApply`) |
| | (itself, via `opencode.json`) | opencode (loads every rule, no path scoping) |
| `ai/global/AGENTS.md` | `claude/.claude/CLAUDE.md` -> `~/.claude/CLAUDE.md` | Claude Code, all projects |
| | `opencode/.config/opencode/global-rules.md` | opencode, all projects (`instructions`) |
| `AGENTS.md` (root, hand-written) | `CLAUDE.md` imports it | opencode, Cursor and Claude Code |
| `ai/skills/<name>/SKILL.md` | symlinked as a directory into `~/.claude/skills/` by `ai/link-skills` | Claude Code, opencode and Cursor (all read that path) |

## Workflow

- Change a rule in `ai/rules/` (or `ai/global/AGENTS.md`), then run `make rules` (`ai/sync`).
- The pre-commit hook `ai-rules` regenerates and fails the commit once if files changed: `git add`
  them and commit again. CI runs `ai/sync --check`.
- Rule frontmatter: `description` (required) and `paths` (YAML list of globs). No `paths` means the
  rule always applies.
- A new generated target needs a Stow package listed in `STOW_PACKAGES` and a re-stow.

## Skills

- `ai/skills/<name>/` holds one skill each (frontmatter `name` = directory name, `description`). `ai/sync`
  validates them; `install.sh` and `make stow` run `ai/link-skills`. The skill *directory* is symlinked, not
  the file: Claude Code documents symlinked skill folders, a symlinked `SKILL.md` is not documented.
- `add-global-rule` adds a rule to `ai/global/AGENTS.md`; it is the way to extend the personal ruleset.

## Tool facts

- Cursor only reads `.mdc` rule files (`globs` is one comma separated string). Its personal "User
  Rules" are set in the app (Settings -> Rules): paste `ai/global/AGENTS.md` there.
- With an `AGENTS.md` and a `CLAUDE.md` Claude Code reads only `CLAUDE.md`, which imports `AGENTS.md`
  (`@AGENTS.md`). opencode reads `AGENTS.md` and ignores `CLAUDE.md` then.
- Hand-written files in `.claude/rules/` or `.cursor/rules/` without the "Generated from" marker are
  left alone by `ai/sync`.
