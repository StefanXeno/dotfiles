# Memory

A private, persistent memory file is loaded into every session:
`~/.config/opencode/memory/memory.md`

- Treat its content as background knowledge about the user and their setup.
- When the user says "remember ..." (or clearly states a lasting preference, fact or decision),
  append ONE short bullet line to that file with the edit/write tool. Do not rewrite or reorder existing lines.
- When the user says "forget ...", delete the matching line.
- Never store secrets (passwords, tokens, keys).
- Do not mention saving a memory unless the user asked for it.
