# git Cheatsheet

Config is split into public (`~/.gitconfig`) and private (`~/.gitconfig.local`).

## Aliases

| Alias | Command | What it does |
|---|---|---|
| `git st` | `git status` | Working tree status |
| `git lg` | `git log --oneline --graph --decorate --all` | Pretty branch graph |
| `git whoami` | shows `user.name` + `user.email` | Active identity on this machine |

## Commit Signing (SSH)

All commits and tags are signed by default (`gpgsign = true`).

| Task | Command |
|---|---|
| Verify last commit signature | `git log --show-signature -1` |
| Test signing | `git commit --allow-empty -m "test: verify SSH signing"` |
| Show active signing key | `git config user.signingkey` |

Signing keys are **per machine** — path is set in `~/.gitconfig.local`.

## SSH Signing Setup (new machine)

```bash
# 1. Generate a signing key
ssh-keygen -t ed25519 \
  -C "username@machinename" \
  -f ~/.ssh/id_ed25519_signing_MACHINENAME

# 2. Add to allowed_signers
echo "your@email.com $(cat ~/.ssh/id_ed25519_signing_MACHINENAME.pub)" \
  >> ~/.ssh/allowed_signers

# 3. Set signingkey in ~/.gitconfig.local
# 4. Add public key to GitHub → Settings → SSH and GPG keys → New signing key
```

## Defaults

| Setting | Value |
|---|---|
| Credential cache | 8 hours (`cache --timeout=28800`) |
| Push upstream | Auto-set on first push (`autoSetupRemote`) |
| Editor | `vim` |
| Signing format | SSH (not GPG) |

## Private Config (`~/.gitconfig.local`)

Required fields before committing:

```ini
[user]
    name  = Your Name
    email = your@email.com
    signingkey = ~/.ssh/id_ed25519_signing_MACHINENAME.pub
```

## Useful Commands

```bash
git config --list --show-origin    # see where each setting comes from
git diff --staged                  # review before commit
git push -u origin HEAD            # push new branch with upstream
```
