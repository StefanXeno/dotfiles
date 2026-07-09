# git Cheatsheet

## Aliases

| Alias | Command | What it does |
|---|---|---|
| `git st` | `git status` | Show modified, staged, and untracked files in the working tree |
| `git lg` | `git log --oneline --graph --decorate --all` | Display a compact graph of commits across all branches |
| `git whoami` | `git config user.name && git config user.email` | Print the Git identity configured on this machine |

## Stash & Branches

| Task | Command | What it does |
|---|---|---|
| Stash changes | `git stash push -m "wip"` | Save uncommitted changes and revert the working tree |
| List stashes | `git stash list` | Show all saved stashes with their messages |
| Restore latest stash | `git stash pop` | Apply the most recent stash and remove it from the list |
| List branches with upstream | `git branch -vv` | Show local branches and their tracking remote branches |
| List remotes | `git remote -v` | Show configured remotes and their fetch/push URLs |

## Signing

| Task | Command | What it does |
|---|---|---|
| Verify last commit signature | `git log --show-signature -1` | Inspect the SSH signature on the most recent commit |
| Test signing | `git commit --allow-empty -m "test: verify SSH signing"` | Create an empty signed commit to verify signing works |
| Show active signing key | `git config user.signingkey` | Print the SSH public key path used for commit signing |
| List trusted signers | `cat ~/.ssh/allowed_signers` | Show email-to-key mappings used to verify SSH signatures locally |

## Useful Commands

```bash
git config --list --show-origin    # Show every Git setting and which file defined it
git diff                           # Show unstaged changes in the working tree
git diff --staged                  # Review staged changes before committing
git add -p                         # Interactively stage hunks instead of whole files
git restore --staged .             # Unstage all currently staged changes
git restore .                      # Discard unstaged changes in tracked files
git fetch --all --prune            # Fetch all remotes and remove deleted remote branches
git pull --rebase                  # Pull remote changes and replay local commits on top
git push -u origin HEAD            # Push the current branch and set upstream tracking
git switch -                       # Jump back to the previously checked-out branch
git log -n 10 --oneline            # Show the last 10 commits in compact form
git show HEAD                      # Show the latest commit including its diff
git clean -fd                      # Remove untracked files and directories (destructive)
```
