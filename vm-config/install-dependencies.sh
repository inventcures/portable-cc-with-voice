#!/bin/bash
# Install Development Dependencies on Portable Claude Code VM
#
# This script installs all necessary development tools and dependencies
# for a productive development environment.
#
# Run this on the VM after first boot: ./install-dependencies.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${GREEN}"
echo "=================================="
echo "Install Development Dependencies"
echo "=================================="
echo -e "${NC}"

# Update package list
log_info "Updating package list..."
sudo apt-get update -y

# Install core development tools
log_info "Installing core development tools..."
sudo apt-get install -y \
    build-essential \
    cmake \
    pkg-config \
    libssl-dev \
    git \
    git-lfs \
    curl \
    wget \
    ca-certificates \
    apt-transport-https

# Install Node.js (via NodeSource for latest LTS)
log_info "Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    log_success "Node.js $(node --version) installed."
else
    log_info "Node.js $(node --version) already installed."
fi

# Install Python tools
log_info "Installing Python tools..."
sudo apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-full \
    python-is-python3

# Install common Python packages
sudo pip3 install --break-system-packages \
    pip \
    setuptools \
    wheel \
    virtualenv \
    pygments

# Install Rust (optional, for Claude Code)
log_info "Checking for Rust..."
if ! command -v rustc &> /dev/null; then
    log_info "Rust not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    log_success "Rust $(rustc --version) installed."
else
    log_info "Rust $(rustc --version) already installed."
fi

# Install Go (optional)
log_info "Checking for Go..."
if ! command -v go &> /dev/null; then
    log_info "Installing Go..."
    wget -q https://go.dev/dl/go1.21.6.linux-amd64.tar.gz -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
    export PATH=$PATH:/usr/local/go/bin
    log_success "Go $(go version) installed."
else
    log_info "Go $(go version | awk '{print $3}') already installed."
fi

# Install Docker (optional)
log_info "Checking for Docker..."
if ! command -v docker &> /dev/null; then
    log_info "Docker not found. To install Docker, see: https://docs.docker.com/engine/install/ubuntu/"
    log_info "Or run: curl -fsSL https://get.docker.com | sh"
else
    log_info "Docker $(docker --version | awk '{print $3}' | tr -d ',') already installed."
fi

# Install terminal utilities
log_info "Installing terminal utilities..."
sudo apt-get install -y \
    tmux \
    zsh \
    neovim \
    htop \
    btop \
    jq \
    ripgrep \
    fzf \
    bat \
    exa \
    duf \
    lazygit \
    mosh-server

# Install Oh My Zsh
log_info "Installing Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "Oh My Zsh installed."
else
    log_info "Oh My Zsh already installed."
fi

# Install useful npm packages
log_info "Installing global npm packages..."
sudo npm install -g \
    typescript \
    ts-node \
    prettier \
    eslint \
    yarn

# Install Claude Code if not present
log_info "Checking for Claude Code..."
if ! command -v claude-code &> /dev/null; then
    log_info "Claude Code not found."
    log_info "Install it with: npm install -g @anthropic-ai/claude-code"
    log_info "Or run: ./setup-claude-code.sh"
else
    log_success "Claude Code is installed."
fi

# Summary
echo ""
echo -e "${GREEN}=================================="
echo "Installation Complete"
echo "==================================${NC}"
echo ""
echo "Installed versions:"
echo "  Node.js:    $(node --version 2>/dev/null || echo 'N/A')"
echo "  npm:        $(npm --version 2>/dev/null || echo 'N/A')"
echo "  Python:     $(python3 --version 2>/dev/null || echo 'N/A')"
echo "  Rust:       $(rustc --version 2>/dev/null || echo 'N/A')"
echo "  Go:         $(go version 2>/dev/null | awk '{print $3}' || echo 'N/A')"
echo "  Git:        $(git --version 2>/dev/null || echo 'N/A')"
echo "  tmux:       $(tmux -V 2>/dev/null || echo 'N/A')"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Set up Claude Code: ./setup-claude-code.sh"
echo "2. Configure your shell: source ~/.zshrc"
echo "3. Start developing!"
echo ""
