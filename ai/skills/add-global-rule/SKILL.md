---
name: add-global-rule
description: Add or change a personal rule that applies to every project and every AI coding tool (Claude Code, opencode, Cursor) by editing its single source in the dotfiles repo. Use when the user asks for a global rule, says "always do X in all projects", "remember this for every project" or "make this a rule for all my AIs".
argument-hint: "[the rule, in your own words]"
---

# Add a global rule

Global rules live in one file of the dotfiles repo: `ai/global/AGENTS.md`. `ai/sync` generates
`~/.claude/CLAUDE.md` (Claude Code) and `~/.config/opencode/global-rules.md` (opencode) from it.
Never edit those two files by hand.

The repo is `${DOTFILES_DIR:-$HOME/dotfiles}` (`$REPO` below). It is public: no secrets or private data
in a rule.

## Steps

1. Read `$REPO/ai/global/AGENTS.md`. If the rule is already covered, or contradicts an existing one, say
   so and propose an edit of that rule instead of adding a duplicate.
2. Check that it is really global. A rule for one project belongs into that project's `AGENTS.md`; a
   rule for the dotfiles repo itself into `$REPO/ai/rules/` (path-scoped). Say so and offer that.
3. Write the rule in English as one imperative bullet (two lines at most), concrete and checkable
   ("Use X", "Never Y"). Put it under the best matching `##` section, or add a short new section if none
   fits. Keep the file short (aim for under 60 lines): merge related bullets instead of piling up.
4. Edit only `$REPO/ai/global/AGENTS.md`.
5. Regenerate with `cd $REPO && make rules`. Then `ai/sync --check` has to pass.
6. Commit with explicit paths (`ai/global/AGENTS.md`, `claude/.claude/CLAUDE.md`,
   `opencode/.config/opencode/global-rules.md`). Message: `feat(ai): global rule - <short summary>`,
   English, with the reason in the body. The hooks must pass; if git cannot find the tools, run it as
   `mise exec -- git commit ...`. Do not push unless asked.
7. Report in the user's chat language: the bullet you added, that Claude Code and opencode load it in new
   sessions (opencode: after `opencode reload`), and the bullet itself once more to paste into Cursor's
   own User Rules (Settings -> Rules), which cannot be set from a file.
