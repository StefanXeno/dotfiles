# git

Config is split into public (`~/.gitconfig`) and private (`~/.gitconfig.local`).

For commands and aliases, see [git Cheatsheet](cheatsheets/git.md).

## Defaults

| Setting | Value |
|---|---|
| Credential cache | 8 hours (`cache --timeout=28800`) |
| Push upstream | Auto-set on first push (`autoSetupRemote`) |
| Editor | `vim` |
| Signing format | SSH (not GPG) |
| Commit signing | Enabled (`gpgsign = true`) |

Signing keys are **per machine** — path is set in `~/.gitconfig.local`.

## Private Config (`~/.gitconfig.local`)

Required fields before committing:

```ini
[user]
    name  = Your Name
    email = your@email.com
    signingkey = ~/.ssh/id_ed25519_signing_MACHINENAME.pub
```

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

Verify signing works:

```bash
git commit --allow-empty -m "test: verify SSH signing"
git log --show-signature -1
```
