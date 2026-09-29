# zsh Cheatsheet

## Aliases

| Alias | Command | What it does |
|---|---|---|
| `clipcopy` | stdin → clipboard | Pipe command output to the system clipboard |
| `dunno` / `idk` / `medunno` / `idontknow` | `¯\_(ツ)_/¯` → clipboard | Copy the shrug emoticon to the clipboard |
| `fd` | `fdfind` | Use Ubuntu's `fdfind` binary under the shorter `fd` name |
| `bat` | `batcat` | Use Ubuntu's `batcat` binary under the shorter `bat` name |
| `sl` | `sl -alFe` | Display the important train animation |
| `dcu` | `docker compose up -d` | Start the current Docker Compose stack in the background |
| `dcd` | `docker compose down` | Stop and remove containers from the current Compose stack |
| `k` | `kubectl` | Run kubectl with working tab completion |
| `kc` | `kubectx` | Switch the active Kubernetes cluster context |
| `kns` | `kubens` | Switch the active Kubernetes namespace |
| `hdoc` | `helm-docs` | Generate README documentation for Helm charts |
| `gl` | `git pull` | Pull the current branch from its remote |
| `jqq` | `$HOME/tools/jqq/jqq.rb` | Query JSON with the local jqq tool |
| `bfg` | `java -jar $HOME/tools/bfg/bfg-1.14.0.jar` | Remove large files or secrets from Git history with BFG |

## Commands

| Command | What it does |
|---|---|
| `tl` | List tmux sessions in fzf and attach to the selected one |
| `tn [name]` | Create a new tmux session, or attach if the name already exists |
| `ta [name]` | Attach to a tmux session, or open an fzf picker when called without a name |
| `cs [query]` | Fuzzy-search cheatsheet commands and aliases (`Alt+H`) |
| `cso` | Pick a cheatsheet markdown file and open it in `bat` |

## fzf

| Action | Keys | What it does |
|---|---|---|
| Search history | `Ctrl+R` | Fuzzy-search command history with full-command preview |
| Find files | `Ctrl+T` | Fuzzy-find files (multi-select with `Tab`) |
| Switch kubeconfig | `Ctrl+K` | fzf picker for kubeconfigs; preview shows contexts/namespaces |
| Find directory | `Alt+C` | Fuzzy-find directories and `cd` into the selection |
| Search cheatsheets | `Alt+H` | Open the `cs` cheatsheet picker from the shell prompt |

## k9s

| Function | What it does |
|---|---|
| `k9s-node-shell-on` | Enable the k9s node shell feature gate for the current shell session |
| `k9s-node-shell-off` | Disable the k9s node shell feature gate again |

## Docker

| Command | What it does |
|---|---|
| `docker compose ps` | Show running containers for the current Compose project |
| `docker compose logs -f` | Follow logs from all services in the current project |
| `docker compose exec SERVICE sh` | Open a shell inside a running service container |
| `docker compose restart SERVICE` | Restart a single service without tearing down the stack |
| `docker compose up -d --build` | Rebuild images and start the stack in the background |

## Kubernetes

| Command | What it does |
|---|---|
| `kubectl get pods -A` | List pods in every namespace |
| `kubectl get ns` | List all namespaces in the cluster |
| `kubectl config current-context` | Show the active cluster context |
| `kubectl get nodes` | List all nodes in the current cluster |
| `kubectl logs -f POD -n NAMESPACE` | Follow logs from a pod in a specific namespace |
| `kubectl describe pod POD -n NAMESPACE` | Show events and status details for a pod |
| `kubectx -` | Switch back to the previous cluster context |
| `kubens -` | Switch back to the previous namespace |
| `kxd f s` | Switch kubeconfig file (same as `Ctrl+K`) |
| `kxd ctx s` | Switch context inside the current kubeconfig |
| `kxd ns s` | Switch namespace in the current context |
| `kxd f c` | Print the currently selected kubeconfig path |

## Useful Commands

```bash
exec zsh                        # Reload the current shell after config changes
echo foo | clipcopy             # Pipe output to the system clipboard
bat README.md                   # Syntax-highlight a file in the terminal
fd -e md cheatsheet             # Find files by name pattern (respects .gitignore)
mise ls                         # List tool versions managed by mise
mise install                    # Install all tools pinned in mise config
mise use TOOL@VERSION           # Set a tool version in the current directory
direnv allow                    # Approve the .envrc in the current directory
stow -t $HOME zsh               # Link the zsh dotfiles package into $HOME
jq . file.json                  # Pretty-print JSON from a file
yq -y . file.yaml               # Convert YAML to JSON on stdout
```
