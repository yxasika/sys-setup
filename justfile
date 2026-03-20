# sys-setup — cross-platform tool installer (macOS + Ubuntu)
#
# Usage:
#   just                      Show this list
#   just setup-base           btop, zoxide, fzf, jq
#   just setup-dev            Go, Bun, nvm + Node LTS
#   just setup-k8s            Docker, kubectl, k3d, helm, tilt
#   just setup-k8s optional=true   Also install kubectx, k9s, stern, dive
#   just setup-all            Run all of the above
#   just setup-all optional=true   Run all, including optional k8s tools
#   just update               Re-download this justfile from GitHub

GITHUB_USER := "yxasika"
GITHUB_REPO := "sys-setup"
GITHUB_BRANCH := "main"
REPO_RAW := "https://raw.githubusercontent.com/" + GITHUB_USER + "/" + GITHUB_REPO + "/" + GITHUB_BRANCH

# Show available recipes
default:
    @just --list --unsorted

# ─── Base ─────────────────────────────────────────────────────────────────────

# Install base CLI tools: btop, zoxide, fzf
setup-base:
    #!/usr/bin/env bash
    set -euo pipefail
    echo ""
    echo "==> Installing base tools..."

    brew install btop zoxide fzf jq

    echo ""
    echo "✓ Base tools installed."
    echo ""
    echo "  Add to your shell profile (~/.zshrc, ~/.bashrc, etc.):"
    echo '  eval "$(zoxide init bash)"   # or: zsh | fish | nushell'
    echo ""
    echo "  fzf key bindings and fuzzy completion:"
    if [ "$(uname)" = "Darwin" ]; then
        echo "  $(brew --prefix)/opt/fzf/install"
    else
        echo "  $(brew --prefix)/opt/fzf/install"
    fi
    echo ""

# ─── Dev ──────────────────────────────────────────────────────────────────────

# Install dev tools: Go, Bun, nvm + Node LTS
setup-dev:
    #!/usr/bin/env bash
    set -euo pipefail
    echo ""
    echo "==> Installing dev tools..."

    # ── Go ──────────────────────────────────────────────────────────────────
    echo "--> Go"
    brew install go

    # ── Bun ─────────────────────────────────────────────────────────────────
    echo "--> Bun"
    brew install bun

    # ── nvm + Node LTS ──────────────────────────────────────────────────────
    echo "--> nvm"
    if [ ! -d "$HOME/.nvm" ]; then
        NVM_VERSION="v0.40.3"
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash
    else
        echo "    nvm already installed, skipping"
    fi

    # Source nvm in this shell to install Node immediately
    export NVM_DIR="$HOME/.nvm"
    # shellcheck disable=SC1091
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

    echo "--> Node LTS"
    nvm install --lts
    nvm use --lts
    nvm alias default 'lts/*'

    echo ""
    echo "✓ Dev tools installed."
    echo ""
    echo "  nvm is sourced automatically via your shell profile."
    echo "  Run 'nvm install --lts' again after opening a new shell if Node is missing."
    echo ""

# ─── Kubernetes ───────────────────────────────────────────────────────────────

# Install Kubernetes tools. Pass optional=true to also install kubectx, k9s, stern, dive
setup-k8s optional="false":
    #!/usr/bin/env bash
    set -euo pipefail
    echo ""
    echo "==> Installing Kubernetes tools..."

    # ── Docker ──────────────────────────────────────────────────────────────
    echo "--> Docker"
    if command -v docker &>/dev/null; then
        echo "    docker already installed, skipping"
    else
        if [ "$(uname)" = "Darwin" ]; then
            brew install --cask docker
            echo "    Docker Desktop installed — launch it from Applications to start the daemon."
        else
            curl -fsSL https://get.docker.com | sh
            sudo usermod -aG docker "$USER"
            echo "    Docker installed. Log out and back in for group membership to take effect."
        fi
    fi

    # ── kubectl ─────────────────────────────────────────────────────────────
    echo "--> kubectl"
    brew install kubectl

    # ── k3d ─────────────────────────────────────────────────────────────────
    echo "--> k3d"
    brew install k3d

    # ── helm ────────────────────────────────────────────────────────────────
    echo "--> helm"
    brew install helm

    # ── tilt ────────────────────────────────────────────────────────────────
    echo "--> tilt"
    brew install tilt

    # ── Optional tools ──────────────────────────────────────────────────────
    if [ "{{optional}}" = "true" ]; then
        echo ""
        echo "--> Optional tools: kubectx, k9s, stern, dive"
        brew install kubectx k9s stern dive
    fi

    echo ""
    echo "✓ Kubernetes tools installed."
    if [ "{{optional}}" = "true" ]; then
        echo "✓ Optional tools installed (kubectx, k9s, stern, dive)."
    else
        echo ""
        echo "  Tip: run 'just setup-k8s optional=true' to also install kubectx, k9s, stern, dive."
    fi
    echo ""

# ─── All ──────────────────────────────────────────────────────────────────────

# Run all setup recipes. Pass optional=true to include optional k8s tools
setup-all optional="false":
    @echo ""
    @echo "Running full setup (optional={{ optional }})..."
    just setup-base
    just setup-dev
    just setup-k8s optional={{ optional }}
    @echo ""
    @echo "✓ All done!"
    @echo ""

# ─── Maintenance ──────────────────────────────────────────────────────────────

# Re-download this justfile from GitHub to get the latest version
update:
    #!/usr/bin/env bash
    set -euo pipefail
    DEST="$(realpath "{{justfile_directory()}}/justfile")"
    echo "Updating justfile from GitHub..."
    curl -fsSL "{{REPO_RAW}}/justfile" -o "$DEST"
    echo "✓ Updated $DEST"
