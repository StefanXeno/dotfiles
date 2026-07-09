# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).
Built for Ubuntu (WSL2 + native), themed with Dracula. 🧛

I vibe coded my dotfiles. Let's see if this was a good idea... - StefanXeno

## 🛠️ Stack

| Tool | Purpose |
|---|---|
| [GNU Stow](https://www.gnu.org/software/stow/) | Symlink management |
| [Oh My Zsh](https://ohmyz.sh/) | Zsh framework |
| [Starship](https://starship.rs/) | Shell prompt |
| [mise](https://mise.jdx.dev/) | Tool version management |
| [tmux](https://github.com/tmux/tmux) + [TPM](https://github.com/tmux-plugins/tpm) | Terminal multiplexer |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |

## 📁 Structure

```
dotfiles/
├── git/
│   └── .gitconfig              # Public-safe base config (SSH signing, aliases)
├── zsh/
│   ├── .zshrc                  # Shell orchestrator — sources ~/.zsh/*.zsh modules
│   ├── bin/
│   │   ├── cs-parse-cheatsheets.awk  # Markdown table parser for cs / Alt+H
│   │   └── notify-send               # WSL/Linux notify-send shim (on PATH via ~/bin)
│   └── .zsh/
│       ├── options.zsh         # History, shell options, environment
│       ├── fzf.zsh             # fzf defaults and key-binding options
│       ├── aliases.zsh         # Aliases and kubectl wrapper (`k`)
│       ├── tmux.zsh            # tmux helpers: ta, tn, tl
│       ├── cheatsheets.zsh     # cs / cso / Alt+H cheatsheet search
│       ├── completions.zsh     # Lazy-loaded tool completions
│       └── k9s-functions.zsh   # Custom k9s helper functions
├── tmux/
│   └── .tmux.conf
├── docs/
│   ├── cheatsheets/            # Commands & aliases only (used by cs / Alt+H)
│   │   ├── tmux.md
│   │   ├── zsh-fzf.md
│   │   └── git.md
│   ├── tmux.md                 # Full tmux key binding reference
│   ├── zsh.md                  # Plugins, fzf bindings, shell options
│   └── git.md                  # SSH signing setup, defaults, private config
├── starship/
│   └── .config/
│       └── starship.toml
├── mise/
│   └── .config/
│       └── mise/
│           └── config.toml
├── test/                       # Docker-based test environment
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── run.sh
└── install.sh                  # Idempotent install script
```

Each top-level directory is a **Stow package** and can be installed independently:

```bash
stow --no-folding -t "$HOME" zsh     # install only zsh config
stow -D -t "$HOME" zsh               # remove only zsh config
```

## 📖 Cheatsheets

Quick command reference (searchable via `cs` / `Alt+H`):

- [tmux](docs/cheatsheets/tmux.md) — shell commands
- [zsh](docs/cheatsheets/zsh-fzf.md) — aliases and helpers
- [git](docs/cheatsheets/git.md) — aliases and signing commands

Detailed guides:

- [tmux keys & plugins](docs/tmux.md)
- [zsh & fzf](docs/zsh.md)
- [git setup](docs/git.md)

## 🚀 Fresh Machine Setup

```bash
git clone git@github.com:StefanXeno/dotfiles.git ~/dotfiles
bash ~/dotfiles/install.sh
```

The install script handles:
- APT packages (`zsh`, `tmux`, `stow`, `bat`, `fd-find`, ...)
- Oh My Zsh + custom plugins
- Stow symlinks for all packages
- mise + all tools from `config.toml`
- Starship
- TPM (Tmux Plugin Manager)
- Local config templates

After install:

```bash
# 1. Fill in machine-specific git identity
vim ~/.gitconfig.local

# 2. Fill in private shell config
vim ~/.zshrc.local

# 3. Generate a signing key for this machine (see SSH Signing below)

# 4. Start a new shell session
exec zsh

# 5. Open tmux — plugins are pre-installed by install.sh (prefix + U to update)
tmux
```

Cheatsheets (`cs` / `Alt+H`) read from `docs/cheatsheets/` in the dotfiles clone.
`install.sh` sets `DOTFILES_DIR` in `~/.zshrc.local`; override if your clone lives elsewhere.

## 🔐 Private / Machine-Specific Config

Sensitive and machine-specific configuration is **never committed**.
Two local override files are created automatically by `install.sh`:

### `~/.gitconfig.local`
```ini
[user]
    name       = Your Name
    email      = your@email.com
    signingkey = ~/.ssh/id_ed25519_signing_MACHINENAME.pub

[author]
    name  = Your Name
    email = your@email.com
```

### `~/.zshrc.local`
```zsh
# Work aliases, API keys, proxy settings, etc.
# export WORK_API_KEY=""
# alias vpn="sudo openconnect vpn.company.com"
```

## 🔑 SSH Signing Setup

Commits are signed with SSH keys. Each machine gets its own signing key
so you can see in the git log where a commit was made from.

```bash
# Generate a signing key for this machine
ssh-keygen -t ed25519 \
  -C "username@machinename" \
  -f ~/.ssh/id_ed25519_signing_MACHINENAME

# Add to allowed_signers
echo "your@email.com $(cat ~/.ssh/id_ed25519_signing_MACHINENAME.pub)" \
  >> ~/.ssh/allowed_signers

# Add the public key to GitHub:
# Settings → SSH and GPG keys → New signing key
```

Verify signing works:
```bash
git commit --allow-empty -m "test: verify SSH signing"
git log --show-signature -1
```

## 🧪 Testing

A Docker-based test environment is included so you can test changes
before applying them to a real machine:

```bash
# Full end-to-end test
./test/run.sh install

# Drop into zsh after successful install
./test/run.sh shell

# Debug with bash
./test/run.sh bash

# Force rebuild without cache
./test/run.sh rebuild

# Nuke everything and start fresh
./test/run.sh reset
```

## 📦 Adding a New Tool

```bash
# 1. Create a stow package directory
mkdir -p ~/dotfiles/newtool

# 2. Move the config file into the package
mv ~/.newtoolrc ~/dotfiles/newtool/.newtoolrc

# 3. Create the symlink via stow
cd ~/dotfiles && stow --no-folding -t "$HOME" newtool

# 4. Commit
git add . && git commit -m "feat: add newtool config"
```

## 🔄 Updating

```bash
cd ~/dotfiles
git pull
# Re-stow if new files were added
stow --no-folding -t "$HOME" zsh   # example
```

### Updating pinned mise tools

Infrastructure and daily-driver tools are **pinned** in `mise/.config/mise/config.toml`.
Misc tools (`jqp`, `dotenvx`, `qdns`, `s3cmd`, `pipx`) stay on `latest`.

```bash
# See available versions for a tool
mise ls-remote terraform

# Bump the pin in config.toml, then install
mise install

# Upgrade only the "latest" tools
mise upgrade jqp dotenvx qdns pipx
```

### Updating pinned OMZ custom plugins

Custom plugins are **pinned** in `install.sh` → `OMZ_CUSTOM_PLUGIN_REFS` and cloned during install.

```bash
# Bump the pin in install.sh, then re-run install (or git -C the plugin dir checkout)
bash ~/dotfiles/install.sh
```

### Updating pinned Oh My Zsh core

OMZ itself is **pinned** in `install.sh` → `OMZ_REF` (commit SHA on `ohmyzsh/ohmyzsh`).

```bash
# Bump OMZ_REF in install.sh, remove ~/.oh-my-zsh, then re-run install
rm -rf ~/.oh-my-zsh
bash ~/dotfiles/install.sh
```

### Updating pinned TPM plugins

tmux plugins are **pinned** in `install.sh` → `TPM_PLUGIN_REFS` and cloned during install.

```bash
# Bump the pin in install.sh, then re-run install (or clone manually)
bash ~/dotfiles/install.sh

# Or update to latest inside tmux (does not change install.sh pins)
# prefix + U
```
