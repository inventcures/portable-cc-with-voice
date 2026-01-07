#!/bin/bash
# User Environment Setup Script
#
# This script configures the user environment for optimal
# development experience on the Portable Claude Code VM.
#
# Run this as your user (not as root): ./user-setup.sh

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
echo "User Environment Setup"
echo "=================================="
echo -e "${NC}"

# Get the project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Set up zsh as default shell
if [[ "$SHELL" != */zsh ]]; then
    log_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    log_success "Default shell changed to zsh."
    log_warning "Log out and back in for this to take effect."
else
    log_info "zsh is already the default shell."
fi

# Copy tmux configuration
log_info "Setting up tmux configuration..."
if [[ -f "$PROJECT_ROOT/tmux/.tmux.conf" ]]; then
    cp "$PROJECT_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
    log_success "tmux configuration installed."
else
    log_warning "tmux configuration not found at $PROJECT_ROOT/tmux/.tmux.conf"
fi

# Create project directory
CODE_DIR="$HOME/Code"
log_info "Creating code directory..."
mkdir -p "$CODE_DIR"
log_success "Created $CODE_DIR"

# Set up git
log_info "Configuring git..."
if [[ -z "$(git config --global user.name)" ]]; then
    read -p "Enter your git user name: " GIT_NAME
    git config --global user.name "$GIT_NAME"
fi
if [[ -z "$(git config --global user.email)" ]]; then
    read -p "Enter your git email: " GIT_EMAIL
    git config --global user.email "$GIT_EMAIL"
fi
log_success "Git configured."

# Set up useful git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --pretty=format:%h %s --graph --oneline --all'

# Create .gitignore
log_info "Creating global .gitignore..."
cat > "$HOME/.gitignore_global" << 'EOF'
# OS
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Node
node_modules/
npm-debug.log
yarn-error.log

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
ENV/
.venv/

# Rust
target/
**/*.rs.bk
Cargo.lock

# Environment
.env
.env.local
.env.*.local
EOF
git config --global core.excludesfile "$HOME/.gitignore_global"
log_success "Global .gitignore created."

# Set up SSH config
log_info "Setting up SSH config..."
SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"
if [[ ! -f "$SSH_CONFIG" ]]; then
    cat > "$SSH_CONFIG" << 'EOF'
# SSH configuration for Portable Claude Code
#
# Add your hosts here, or they will be added automatically by Termius

# Keep connections alive
ServerAliveInterval 60
ServerAliveCountMax 3

# Compression
Compression yes

# Use known hosts file
UserKnownHostsFile ~/.ssh/known_hosts
EOF
    chmod 600 "$SSH_CONFIG"
    log_success "SSH configuration created."
else
    log_info "SSH configuration already exists."
fi

# Create useful scripts directory
SCRIPTS_DIR="$HOME/.local/bin"
mkdir -p "$SCRIPTS_DIR"

# Add scripts to PATH if not already
if ! grep -q "$SCRIPTS_DIR" "$HOME/.zshrc" 2>/dev/null; then
    cat >> "$HOME/.zshrc" << EOF

# User scripts
export PATH="\$PATH:$SCRIPTS_DIR"
EOF
    log_success "Added $SCRIPTS_DIR to PATH."
fi

# Summary
echo ""
echo -e "${GREEN}=================================="
echo "User Environment Setup Complete"
echo "==================================${NC}"
echo ""
echo "Configured:"
echo "  Shell:     zsh"
echo "  Code dir:  $CODE_DIR"
echo "  Git:       $(git config user.name) <$(git config user.email)>"
echo "  Scripts:   $SCRIPTS_DIR"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Log out and back in for shell changes to take effect"
echo "2. Or run: source ~/.zshrc"
echo "3. Set up your development projects in $CODE_DIR"
echo ""
