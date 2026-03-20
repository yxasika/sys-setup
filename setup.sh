#!/usr/bin/env bash
set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
GITHUB_USER="yxasika"
GITHUB_REPO="sys-setup"
GITHUB_BRANCH="main"
REPO_RAW="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"

DEFAULT_INSTALL_DIR="$HOME/.sys-setup"
INSTALL_DIR="${1:-$DEFAULT_INSTALL_DIR}"

# ─── Output helpers ───────────────────────────────────────────────────────────
if [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'
  YELLOW='\033[1;33m'; BOLD='\033[1m'; NC='\033[0m'
else
  RED=''; GREEN=''; BLUE=''; YELLOW=''; BOLD=''; NC=''
fi

info()    { printf "${BLUE}==> ${NC}%s\n" "$*"; }
success() { printf "${GREEN}✓ ${NC}%s\n" "$*"; }
warn()    { printf "${YELLOW}! ${NC}%s\n" "$*"; }
error()   { printf "${RED}✗ ${NC}%s\n" "$*" >&2; exit 1; }
header()  { printf "\n${BOLD}%s${NC}\n%s\n\n" "$*" "$(printf '─%.0s' $(seq 1 ${#1}))"; }

# ─── Platform detection ───────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
  Linux*)  PLATFORM="linux" ;;
  Darwin*) PLATFORM="macos" ;;
  *)       error "Unsupported OS: $OS" ;;
esac

# ─── Shell profile detection ──────────────────────────────────────────────────
detect_shell_profile() {
  local shell_name
  shell_name="$(basename "${SHELL:-bash}")"
  case "$shell_name" in
    zsh)  echo "$HOME/.zshrc" ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    bash)
      if [ "$PLATFORM" = "macos" ]; then
        echo "$HOME/.bash_profile"
      else
        echo "$HOME/.bashrc"
      fi
      ;;
    *) echo "$HOME/.bashrc" ;;
  esac
}

SHELL_PROFILE="$(detect_shell_profile)"

add_to_profile() {
  local line="$1"
  if ! grep -qF "$line" "$SHELL_PROFILE" 2>/dev/null; then
    echo "$line" >> "$SHELL_PROFILE"
    success "Added to $SHELL_PROFILE"
    info "  $line"
  fi
}

# ─── Homebrew ─────────────────────────────────────────────────────────────────
install_homebrew() {
  if command -v brew &>/dev/null; then
    success "Homebrew already installed"
    return
  fi

  info "Installing Homebrew..."

  if [ "$PLATFORM" = "linux" ]; then
    info "Installing Homebrew dependencies via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq build-essential procps curl file git
  fi

  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to current session and shell profile
  local brew_env_line
  if [ "$PLATFORM" = "linux" ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew_env_line='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
  elif [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    brew_env_line='eval "$(/opt/homebrew/bin/brew shellenv)"'
  else
    eval "$(/usr/local/bin/brew shellenv)"
    brew_env_line='eval "$(/usr/local/bin/brew shellenv)"'
  fi

  add_to_profile "$brew_env_line"
  success "Homebrew installed"
}

# ─── git ──────────────────────────────────────────────────────────────────────
install_git() {
  if command -v git &>/dev/null; then
    success "git already installed"
    return
  fi
  info "Installing git..."
  brew install git
  success "git installed"
}

# ─── just ─────────────────────────────────────────────────────────────────────
install_just() {
  if command -v just &>/dev/null; then
    success "just already installed"
    return
  fi
  info "Installing just..."
  brew install just
  success "just installed"
}

# ─── Download justfile ────────────────────────────────────────────────────────
download_justfile() {
  info "Creating install directory: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"

  info "Downloading justfile from GitHub..."
  curl -fsSL "$REPO_RAW/justfile" -o "$INSTALL_DIR/justfile"
  success "justfile saved to $INSTALL_DIR/justfile"
}

# ─── Main ─────────────────────────────────────────────────────────────────────
header "sys-setup bootstrap"

info "Platform : $PLATFORM"
info "Install  : $INSTALL_DIR"
info "Profile  : $SHELL_PROFILE"
echo ""

install_homebrew
install_git
install_just
download_justfile

echo ""
success "Bootstrap complete!"
echo ""
printf "${BOLD}Next steps:${NC}\n"
printf "  cd %s\n" "$INSTALL_DIR"
printf "  just              # list available recipes\n"
printf "  just setup-all    # install everything\n"
printf "  just setup-all optional=true  # include optional k8s tools\n"
echo ""
warn "Reload your shell or run: source $SHELL_PROFILE"
echo ""
