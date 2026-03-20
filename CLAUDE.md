# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A two-file cross-platform setup system for macOS and Ubuntu. A bootstrap shell script installs the bare minimums (Homebrew, git, just) and downloads the justfile; the justfile contains the actual tool installation recipes.

## Files

- `setup.sh` — Bootstrap script. Hosted as a raw GitHub artifact. Installs Homebrew, git, just, then downloads the justfile to `~/.sys-setup` (or a custom path passed as `$1`).
- `justfile` — All tool installation recipes. Intended to live at `~/.sys-setup/justfile` on the user's machine.

## Justfile recipes

```
just setup-base                  # btop, zoxide, fzf
just setup-dev                   # Go, Bun, nvm + Node LTS
just setup-k8s                   # docker, kubectl, k3d, helm, tilt
just setup-k8s optional=true     # + kubectx, k9s, stern, dive
just setup-all                   # all of the above
just setup-all optional=true     # all + optional k8s tools
just update                      # re-download justfile from GitHub
```

## Design decisions

- **Homebrew is the primary package manager** for both platforms. Works on Linux (Linuxbrew) and macOS.
- **Docker is handled separately per platform**: on Linux it uses the official `get.docker.com` script (installs full Docker Engine + daemon); on macOS it installs Docker Desktop via `brew --cask`.
- **nvm uses the official curl installer**, not `brew install nvm`, because the Homebrew formula requires additional manual PATH wiring that the curl script handles automatically.
- **Optional k8s tools** are gated by `optional=true` parameter, not a separate recipe, so `setup-all optional=true` naturally composes.
- `GITHUB_USER`, `GITHUB_REPO`, and `GITHUB_BRANCH` are defined at the top of both files — update these when the repo is renamed or transferred.

## GitHub artifact URL

The bootstrap script is meant to be run via:
```bash
curl -fsSL https://raw.githubusercontent.com/sgoetz/sys-setup/main/setup.sh | bash
# or with a custom install dir:
curl -fsSL https://raw.githubusercontent.com/sgoetz/sys-setup/main/setup.sh | bash -s ~/.dotfiles
