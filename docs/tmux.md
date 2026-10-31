# tmux

Prefix is **Ctrl+a** (not the default Ctrl+b).

For key bindings and shell commands, see [tmux Cheatsheet](cheatsheets/tmux.md).

## Notes

### Pane rotation

With only **two panes**, forwards and backwards look identical (both just swap positions). Use three or more panes to verify direction.

### Scratchpad

`prefix` + `` ` `` opens a **floating popup** (80%×80%) with a temporary shell on top of your layout.
Use it for one-off commands, notes, or `htop` without touching your pane arrangement.
Close it by exiting the shell (`exit` or `Ctrl+d`) or pressing the binding again.

### Ollama menu

`Ctrl+,` and `Ctrl+.` (no prefix) are forwarded to zsh: `Ctrl+,` opens `ollama-menu` inline to switch local AI models on/off, `Ctrl+.` explains the current command line — see [zsh docs](zsh.md#local-ai-ollama--opencode).

### Zoom

`prefix` + `z` toggles the current pane to full window size (press again to restore).

### Copy mode

Yanked text is kept in the tmux buffer. With **tmux-yank** installed, it can also land in the system clipboard (depends on platform).

### Plugins

Plugins are pinned in `install.sh` (`TPM_PLUGIN_REFS`) and cloned on install.
Use `prefix` + `U` only when you want the latest upstream — bump pins in `install.sh` for reproducible updates.

Plugins in use: `tmux-sensible`, `tmux-yank`, `tmux-notify`, `dracula/tmux`.

### tmux-notify

On WSL, notifications use **wsl-notify-send.exe** (optional, installed via `install.sh` into `~/bin/`). After changing PATH in tmux.conf, reload with `prefix` + `R` (or restart the tmux server).

## Mouse

Mouse support is enabled — click to focus panes/windows, scroll in panes, drag pane borders to resize.

## New panes

New panes open in the current working directory automatically (via `-c "#{pane_current_path}"` in `~/.tmux.conf`).

## Status bar

`status-right` is built by the Dracula theme; `tmux.conf` appends the output of `~/bin/tmux-ai-status` after it:
Claude Code usage (orange) and the Ollama model that is loaded (purple). A segment is only drawn while it exists.
Outside tmux the same two values appear in the starship prompt.
