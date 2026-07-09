# tmux Cheatsheet

Prefix is **Ctrl+a** (not the default Ctrl+b).

## Sessions

| Action | Keys |
|---|---|
| New session | `tmux` or `tmux new -s name` |
| Detach (keep running) | `prefix` + `d` |
| List sessions | `tmux ls` |
| Attach to session | `tmux attach -t name` |
| Kill session | `tmux kill-session -t name` |

## Windows

| Action | Keys |
|---|---|
| New window | `prefix` + `c` |
| Next / previous window | `prefix` + `n` / `prefix` + `p` |
| Select window by number | `prefix` + `0`–`9` |
| Rename window | `prefix` + `r` |
| Kill window | `prefix` + `&` |

## Panes

| Action | Keys |
|---|---|
| Split horizontal (side by side) | `prefix` + `\` |
| Split vertical (top/bottom) | `prefix` + `-` |
| New pane opens in current directory | automatic (via `-c "#{pane_current_path}"`) |
| Select pane | `Alt` + arrow keys |
| Rotate panes backwards | `Alt` + `Shift` + `←` or `prefix` + `<` |
| Rotate panes forwards | `Alt` + `Shift` + `→` or `prefix` + `>` |
| Re-tile all panes evenly | `prefix` + `t` |
| Kill pane | `prefix` + `x` |
| Zoom pane (toggle) | `prefix` + `z` |
| Show pane numbers briefly | `prefix` + `q` |
| Sync input to all panes | `prefix` + `s` (toggle) |

With only **two panes**, forwards and backwards look identical (both just swap positions). Use three or more panes to verify direction.

## Copy Mode (vi-style)

| Action | Keys |
|---|---|
| Enter copy mode | `prefix` + `v` |
| Move | `h` / `j` / `k` / `l` |
| Start selection | `v` |
| Yank to tmux buffer | `y` |
| Exit copy mode | `q` or `Esc` |

Yanked text is kept in the tmux buffer. With **tmux-yank** installed, it can also land in the system clipboard (depends on platform).

## Config & Plugins (TPM)

| Action | Keys |
|---|---|
| Reload config | `prefix` + `R` |
| Install plugins (if missing) | `prefix` + `I` |
| Update plugins to latest | `prefix` + `U` |

Plugins are pinned in `install.sh` (`TPM_PLUGIN_REFS`) and cloned on install.
Use `prefix` + `U` only when you want the latest upstream — bump pins in `install.sh` for reproducible updates.

Plugins in use: `tmux-sensible`, `tmux-yank`, `tmux-notify`, `dracula/tmux`.

### tmux-notify

Monitor the current pane until the shell prompt returns, then notify:

| Action | Keys |
|---|---|
| Monitor pane | `prefix` + `m` |
| Cancel monitor | `prefix` + `M` |

On WSL, notifications use **wsl-notify-send.exe** (optional, installed via `install.sh` into `~/bin/`). Test from a shell:

```bash
notify-send "Test" "Hello from WSL"
```

On managed PCs, Group Policy may block the `.exe` — install is opt-in when running `install.sh`. After changing PATH in tmux.conf, reload with `prefix` + `R` (or restart the tmux server).

## Mouse

Mouse support is enabled — click to focus panes/windows, scroll in panes, drag pane borders to resize.

## Useful Commands (outside tmux)

```bash
tmux source-file ~/.tmux.conf   # reload config from shell
tmux list-keys | grep rotate    # verify rotation bindings
```
