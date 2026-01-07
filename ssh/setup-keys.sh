#!/bin/bash
# SSH Key Setup Script for Portable Claude Code
#
# This script helps set up SSH keys for secure authentication
# between your iOS device and the VM.
#
# Run this on the VM: sudo ./setup-keys.sh
#
# Then copy the public key to Termius on iOS

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SSH_USER="${SUDO_USER:-ubuntu}"
SSH_DIR="/home/$SSH_USER/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

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
echo "SSH Key Setup"
echo "=================================="
echo -e "${NC}"

# Create .ssh directory if it doesn't exist
log_info "Setting up SSH directory..."
if [[ ! -d "$SSH_DIR" ]]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    chown "$SSH_USER:$SSH_USER" "$SSH_DIR"
    log_success "Created SSH directory."
else
    log_info "SSH directory exists."
fi

# Create authorized_keys if it doesn't exist
if [[ ! -f "$AUTHORIZED_KEYS" ]]; then
    touch "$AUTHORIZED_KEYS"
    chmod 600 "$AUTHORIZED_KEYS"
    chown "$SSH_USER:$SSH_USER" "$AUTHORIZED_KEYS"
    log_success "Created authorized_keys file."
fi

# Option 1: Generate a new key pair on the server
log_info "Do you want to generate a new SSH key pair on the server?"
log_info "This is useful if you'll use Termius to import the key."
read -p "Generate key pair? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    KEY_TYPE="${KEY_TYPE:-ed25519}"
    KEY_COMMENT="$SSH_USER@portable-cc"

    log_info "Generating $KEY_TYPE key pair..."
    ssh-keygen -t "$KEY_TYPE" -C "$KEY_COMMENT" -f "$SSH_DIR/id_$KEY_TYPE" -N ""

    chmod 600 "$SSH_DIR/id_$KEY_TYPE"
    chmod 644 "$SSH_DIR/id_$KEY_TYPE.pub"
    chown "$SSH_USER:$SSH_USER" "$SSH_DIR/id_$KEY_TYPE"*

    log_success "Key pair generated."

    # Add to authorized_keys
    cat "$SSH_DIR/id_$KEY_TYPE.pub" >> "$AUTHORIZED_KEYS"
    log_success "Public key added to authorized_keys."

    echo ""
    echo -e "${YELLOW}=================================="
    echo "Public Key (for Termius)"
    echo "==================================${NC}"
    cat "$SSH_DIR/id_$KEY_TYPE.pub"
    echo ""
    echo "Copy this public key and add it to Termius:"
    echo "1. Open Termius on iOS"
    echo "2. Go to Keychain"
    echo "3. Tap '+', then 'Import Key'"
    echo "4. Paste the public key above"
    echo "5. For private key, either:"
    echo "   - Copy the private key from $SSH_DIR/id_$KEY_TYPE"
    echo "   - Or generate a new key in Termius and add the public key here"
    echo ""
fi

# Option 2: Display prompt for adding existing Termius key
echo ""
log_info "If you generated a key in Termius:"
echo ""
echo "1. In Termius, go to Keychain"
echo "2. Tap on your key"
echo "3. Copy the public key"
echo "4. Paste it below (or press Enter to skip)"
echo ""
read -p "Paste public key here: " PASTED_KEY

if [[ -n "$PASTED_KEY" ]]; then
    echo "$PASTED_KEY" >> "$AUTHORIZED_KEYS"
    log_success "Public key added to authorized_keys."
fi

# Show current authorized keys
echo ""
echo -e "${YELLOW}=================================="
echo "Current Authorized Keys"
echo "==================================${NC}"
if [[ -f "$AUTHORIZED_KEYS" ]]; then
    nl -w2 -s'. ' "$AUTHORIZED_KEYS"
    echo ""
    log_info "Total keys: $(wc -l < "$AUTHORIZED_KEYS")"
else
    log_warning "No authorized keys found."
fi

# Test SSH configuration
echo ""
log_info "Testing SSH configuration..."
if sudo sshd -t 0<&-; then
    log_success "SSH configuration is valid."
else
    log_error "SSH configuration has errors. Please check."
    log_info "Run: sudo sshd -t"
fi

# Instructions
echo ""
echo -e "${YELLOW}=================================="
echo "Next Steps"
echo "==================================${NC}"
echo ""
echo "1. Make sure Termius has your SSH key:"
echo "   - Generate in Termius, OR"
echo "   - Import the key displayed above"
echo ""
echo "2. Add the Termius public key to this VM:"
echo "   - It's already added if you pasted it above"
echo "   - Or add it manually to: $AUTHORIZED_KEYS"
echo ""
echo "3. Test connection from iOS:"
echo "   - Make sure Tailscale is connected"
echo "   - In Termius, tap your host to connect"
echo ""
echo "4. For extra security, disable password auth:"
echo "   - Run: sudo ../ssh/harden-sshd.sh"
echo ""
