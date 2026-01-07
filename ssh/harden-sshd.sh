#!/bin/bash
# Apply Hardened SSH Configuration
#
# This script applies the hardened SSH configuration
# from sshd-config.conf to the system.
#
# Usage: sudo ./harden-sshd.sh

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

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

echo -e "${GREEN}"
echo "=================================="
echo "SSH Hardening"
echo "=================================="
echo -e "${NC}"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/sshd-config.conf"

if [[ ! -f "$CONFIG_FILE" ]]; then
    log_error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Backup current config
log_info "Backing up current SSH configuration..."
BACKUP_FILE="/etc/ssh/sshd_config.backup.$(date +%Y%m%d_%H%M%S)"
cp /etc/ssh/sshd_config "$BACKUP_FILE"
log_success "Backup saved to: $BACKUP_FILE"

# Check if sshd_config.d directory exists
if [[ -d "/etc/ssh/sshd_config.d" ]]; then
    log_info "Using sshd_config.d directory..."
    cp "$CONFIG_FILE" /etc/ssh/sshd_config.d/portable-cc.conf
    CONFIG_TARGET="/etc/ssh/sshd_config.d/portable-cc.conf"
else
    log_warning "sshd_config.d not found, appending to main config..."
    cat "$CONFIG_FILE" >> /etc/ssh/sshd_config
    CONFIG_TARGET="/etc/ssh/sshd_config"
fi

# Test configuration
log_info "Testing SSH configuration..."
if sshd -t; then
    log_success "SSH configuration is valid."
else
    log_error "SSH configuration has errors!"
    log_info "Restoring backup..."
    cp "$BACKUP_FILE" /etc/ssh/sshd_config
    log_error "Backup restored. Please fix the errors and try again."
    exit 1
fi

# Restart SSH
log_info "Restarting SSH service..."
if systemctl restart sshd; then
    log_success "SSH service restarted."
elif service ssh restart; then
    log_success "SSH service restarted."
else
    log_error "Failed to restart SSH. You may need to restart manually."
    log_info "Your current session is not affected."
    log_info "Restart manually with: sudo systemctl restart sshd"
    exit 1
fi

# Summary
echo ""
echo -e "${GREEN}=================================="
echo "SSH Hardening Complete"
echo "==================================${NC}"
echo ""
echo "Applied settings from: $CONFIG_FILE"
echo ""
echo "Security changes:"
echo "  - Password authentication: DISABLED"
echo "  - Root login: DISABLED"
echo "  - X11 forwarding: DISABLED"
echo "  - Max auth attempts: 3"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC}"
echo "1. Make sure your SSH key is working BEFORE closing this session!"
echo "2. Test connection from a new terminal:"
echo "   ssh ubuntu@<tailscale-ip>"
echo "3. Backup location: $BACKUP_FILE"
echo "4. To restore original:"
echo "   sudo cp $BACKUP_FILE /etc/ssh/sshd_config"
echo "   sudo systemctl restart sshd"
echo ""
