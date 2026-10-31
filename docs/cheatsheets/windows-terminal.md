# Windows Terminal Cheatsheet

Settings live in `windows-terminal/settings.json` (synced with `wt-settings`, not stowed).

## Shortcuts

| Action | Keys | What it does |
|---|---|---|
| Summon terminal | `Ctrl+Alt+T` | Bring Windows Terminal to the front from anywhere |
| Quake mode | `Win` + backtick | Drop-down terminal from the top of the screen |
| Copy | `Ctrl+C` | Copy the selection (copy-on-select is also on) |
| Paste | `Ctrl+V` | Paste from the clipboard |
| Find | `Ctrl+Shift+F` | Search the scrollback |
| Split pane | `Alt+Shift+D` | Split the current pane (duplicates the profile) |
| Ollama menu | `Ctrl+,` | Sends CSI-u `\e[44;5u` to the shell instead of opening Settings |
| Explain command | `Ctrl+.` | Sends CSI-u `\e[46;5u` to the shell (local AI explanation) |

## Commands

| Command | What it does |
|---|---|
| `wt-settings` | Check whether Windows Terminal settings match the dotfiles copy |
| `wt-settings diff` | Show differences between live Windows Terminal settings and the repo |
| `wt-settings push` | Copy repo settings to Windows Terminal (backs up the live file) |
| `wt-settings pull` | Copy live Windows Terminal settings into the repo after UI changes |
