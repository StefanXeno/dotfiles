# tmux Cheatsheet

Prefix is **Ctrl+a**.

## Sessions

| Action | Keys | What it does |
|---|---|---|
| New session | `tmux` or `tmux new -s name` | Start a new tmux session; add `-s name` to pick a session name |
| Detach | `prefix` + `d` | Leave the session running in the background and return to your normal shell |
| List sessions | `tmux ls` | Show all running tmux sessions and whether they are attached |
| Attach to session | `tmux attach -t name` | Reconnect to a running session by name |
| Attach or create | `tmux new-session -A -s name` | Attach to session `name`, or create it if missing |
| Kill session | `tmux kill-session -t name` | Terminate a session and all of its windows and panes |

## Windows

| Action | Keys | What it does |
|---|---|---|
| New window | `prefix` + `c` | Open a new window in the current session |
| Next window | `prefix` + `n` | Switch to the next window |
| Previous window | `prefix` + `p` | Switch to the previous window |
| Select window by number | `prefix` + `0`–`9` | Jump directly to window 0–9 |
| Rename window | `prefix` + `r` | Change the name of the current window |
| Kill window | `prefix` + `&` | Close the current window and all of its panes |

## Panes

| Action | Keys | What it does |
|---|---|---|
| Split horizontal | `prefix` + `\` | Split the current pane side by side |
| Split vertical | `prefix` + `-` | Split the current pane top and bottom |
| Select pane | `Alt` + arrow keys | Move focus to the pane in that direction |
| Rotate panes backwards | `Alt` + `Shift` + `←` or `prefix` + `<` | Rotate pane positions counter-clockwise |
| Rotate panes forwards | `Alt` + `Shift` + `→` or `prefix` + `>` | Rotate pane positions clockwise |
| Re-tile panes | `prefix` + `t` | Reset all panes in the window to an even tiled layout |
| Kill pane | `prefix` + `x` | Close the current pane |
| Zoom pane | `prefix` + `z` | Toggle the current pane to full window size |
| Scratchpad | `prefix` + backtick | Open a temporary floating shell popup without changing your layout |
| Show pane numbers | `prefix` + `q` | Briefly display pane numbers for quick targeting |
| Sync panes | `prefix` + `s` | Send the same input to every pane in the window (toggle) |

## Copy Mode

| Action | Keys | What it does |
|---|---|---|
| Enter copy mode | `prefix` + `v` | Enter vi-style copy mode in the current pane |
| Move cursor | `h` / `j` / `k` / `l` | Move around in copy mode |
| Start selection | `v` | Begin a text selection |
| Yank to buffer | `y` | Copy the selection into the tmux buffer |
| Exit copy mode | `q` or `Esc` | Leave copy mode without changing the pane |

## Config & Plugins

| Action | Keys | What it does |
|---|---|---|
| Reload config | `prefix` + `R` | Reload `~/.tmux.conf` without restarting tmux |
| Install plugins | `prefix` + `I` | Install TPM plugins that are not present yet |
| Update plugins | `prefix` + `U` | Update installed TPM plugins to their latest versions |

## Notifications

| Action | Keys | What it does |
|---|---|---|
| Monitor pane | `prefix` + `m` | Notify when the current pane command finishes |
| Cancel monitor | `prefix` + `M` | Stop monitoring the current pane |

## Shell Commands

| Command | What it does |
|---|---|
| `tmux source-file ~/.tmux.conf` | Reload tmux config from a regular shell |
| `tmux list-keys | grep rotate` | Verify that pane rotation bindings are loaded |
| `tmux kill-server` | Stop the tmux server and close all sessions |
| `tmux has-session -t name` | Check whether a session with the given name exists |
| `tmux list-windows -t SESSION` | List all windows inside a session |
| `tmux display-message -p '#S'` | Print the name of the current tmux session |
| `tmux capture-pane -p` | Print the visible pane content to stdout |
| `tmux show-buffer` | Print the tmux copy buffer contents |
| `notify-send "Test" "Hello from WSL"` | Test desktop notifications from WSL |
