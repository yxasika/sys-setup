# sys-setup

Cross-platform tool installer for macOS and Ubuntu, built around [just](https://github.com/casey/just).

## Bootstrap

Run this once on a fresh machine:

```bash
curl -fsSL https://raw.githubusercontent.com/yxasika/sys-setup/main/setup.sh | bash
```

This installs **Homebrew**, **git**, and **just**, then downloads the `justfile` to `~/.sys-setup`.

To use a different install directory:

```bash
curl -fsSL https://raw.githubusercontent.com/yxasika/sys-setup/main/setup.sh | bash -s ~/dotfiles
```

## Usage

```bash
cd ~/.sys-setup
just              # list all recipes
```

### Recipes

| Command                        | Installs                         |
|--------------------------------|----------------------------------|
| `just setup-base`              | btop, zoxide, fzf, jq            |
| `just setup-dev`               | Go, Bun, nvm + Node LTS          |
| `just setup-k8s`               | Docker, kubectl, k3d, helm, tilt |
| `just setup-k8s optional=true` | + kubectx, k9s, stern, dive      |
| `just setup-all`               | Everything above                 |
| `just setup-all optional=true` | Everything + optional k8s tools  |
| `just update`                  | Re-download justfile from GitHub |

### Examples

```bash
# Set up a dev machine
just setup-base
just setup-dev

# Set up a Kubernetes workstation with all tools
just setup-k8s optional=true

# Full install in one shot
just setup-all optional=true
```

## After install

Some tools need a line added to your shell profile (`~/.zshrc`, `~/.bashrc`, etc.):

```bash
# zoxide — smarter cd
eval "$(zoxide init zsh)"   # or bash / fish / nushell

# nvm — already added by the installer, reload your shell if Node is missing
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
```

`fzf` key bindings (Ctrl-R history search, Ctrl-T file picker, Alt-C cd):

```bash
$(brew --prefix)/opt/fzf/install
```

**Docker on Linux**: you need to log out and back in after `setup-k8s` for the `docker` group membership to take effect.

## Keeping up to date

```bash
just update    # pulls the latest justfile from GitHub
```
