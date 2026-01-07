#!/bin/bash
# Claude Code Installation Script
#
# This script installs Claude Code CLI and configures it
# for use with the Portable CC on iOS setup.
#
# Usage: ./setup-claude-code.sh

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
echo "Claude Code Setup"
echo "=================================="
echo -e "${NC}"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    log_error "Node.js is not installed."
    log_info "Run ./install-dependencies.sh first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    log_error "npm is not installed."
    log_info "Run ./install-dependencies.sh first."
    exit 1
fi

# Install Claude Code globally
log_info "Installing Claude Code CLI..."
if npm list -g @anthropic-ai/claude-code &> /dev/null; then
    log_warning "Claude Code is already installed."
    read -p "Reinstall? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo npm uninstall -g @anthropic-ai/claude-code
        sudo npm install -g @anthropic-ai/claude-code
        log_success "Claude Code reinstalled."
    fi
else
    sudo npm install -g @anthropic-ai/claude-code
    log_success "Claude Code installed."
fi

# Show version
echo ""
log_info "Claude Code version:"
claude-code --version 2>/dev/null || echo "  (version check failed)"

# Set up Claude Code directory
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"

log_info "Setting up Claude Code configuration..."
mkdir -p "$HOOKS_DIR"

# Check if settings.json exists
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [[ -f "$SETTINGS_FILE" ]]; then
    log_warning "settings.json already exists."
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Keeping existing settings."
    fi
fi

# Create basic settings.json
if [[ ! -f "$SETTINGS_FILE" ]] || [[ $REPLY =~ ^[Yy]$ ]]; then
    cat > "$SETTINGS_FILE" << 'EOF'
{
  "apiKey": "${ANTHROPIC_API_KEY}",
  "model": "claude-opus-4-5-20251101",
  "maxFileSize": 10000000,
  "maxProjectFileSize": 100000000,
  "contextLimit": 200000,
  "allowedEditLocations": ["project", "home"],
  "hooks": {
    "PreToolUse": [
      {
        "matcher": {
          "tool_name": "AskUserQuestion"
        },
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
EOF
    log_success "Created settings.json"
fi

# Set up notification hook
NOTIFY_HOOK="$HOOKS_DIR/notify.sh"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK_SOURCE="$PROJECT_ROOT/notifications/notify.sh"

if [[ -f "$HOOK_SOURCE" ]]; then
    log_info "Installing notification hook..."
    cp "$HOOK_SOURCE" "$NOTIFY_HOOK"
    chmod +x "$NOTIFY_HOOK"
    log_success "Notification hook installed."
else
    log_warning "Notification hook not found at $HOOK_SOURCE"
    log_info "You can install it later after running the full setup."
fi

# Configure environment
log_info "Setting up environment variables..."

# Add to .zshrc if not present
ZSHRC="$HOME/.zshrc"
if ! grep -q "ANTHROPIC_API_KEY" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" << 'EOF'

# Claude Code Configuration
export ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}"
EOF
    log_success "Added Claude Code environment to .zshrc"
fi

# Summary
echo ""
echo -e "${GREEN}=================================="
echo "Claude Code Setup Complete"
echo "==================================${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Settings:  $SETTINGS_FILE"
echo "  Hooks:     $HOOKS_DIR/"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Set your Anthropic API key:"
echo "   export ANTHROPIC_API_KEY='your-api-key'"
echo ""
echo "2. Or add it to ~/.zshrc:"
echo "   export ANTHROPIC_API_KEY='your-api-key'"
echo ""
echo "3. Configure push notifications:"
echo "   - Edit $NOTIFY_HOOK"
echo "   - Set your ntfy.sh topic"
echo ""
echo "4. Run Claude Code:"
echo "   claude-code"
echo ""
echo -e "${YELLOW}Get your API key:${NC}"
echo "https://console.anthropic.com/"
echo ""
