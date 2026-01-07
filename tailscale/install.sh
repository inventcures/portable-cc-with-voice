#!/bin/bash
# Tailscale Installation and Configuration Script
#
# This script installs Tailscale on the VM and configures it
# for secure SSH access from iOS devices.
#
# Run this script ON THE VM after first boot.
#
# Usage: sudo ./install.sh [OPTIONS]
#
# Options:
#   --ssh         Enable Tailscale SSH (override port 11222)
#   --exit-node   Advertise this VM as an exit node

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
ENABLE_SSH=false
EXIT_NODE=false

for arg in "$@"; do
    case $arg in
        --ssh)
            ENABLE_SSH=true
            ;;
        --exit-node)
            EXIT_NODE=true
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --ssh         Enable Tailscale SSH (override port 11222)"
            echo "  --exit-node   Advertise this VM as an exit node"
            echo ""
            exit 0
            ;;
    esac
done

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
echo "Tailscale Installation"
echo "=================================="
echo -e "${NC}"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    log_error "This script must be run as root (use sudo)"
    exit 1
fi

# Check if Tailscale is already installed
if command -v tailscale &> /dev/null; then
    log_warning "Tailscale is already installed."
    read -p "Reinstall? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Skipping installation."
    else
        log_info "Reinstalling Tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh
    fi
else
    log_info "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
    log_success "Tailscale installed."
fi

echo ""

# Build the tailscale up command
TS_CMD="sudo tailscale up"

if [[ "$ENABLE_SSH" == true ]]; then
    TS_CMD="$TS_CMD --ssh=11222"
    log_info "Tailscale SSH will be enabled on port 11222"
fi

if [[ "$EXIT_NODE" == true ]]; then
    TS_CMD="$TS_CMD --advertise-exit-node"
    log_info "VM will be advertised as an exit node"
fi

echo ""
echo -e "${YELLOW}=================================="
echo "Authentication Required"
echo "==================================${NC}"
echo ""
echo "You need to authenticate this machine with Tailscale."
echo ""
echo "Run the following command to authenticate:"
echo ""
echo -e "${GREEN}$TS_CMD${NC}"
echo ""
echo "This will open a browser window where you'll:"
echo "1. Sign in to your Tailscale account"
echo "2. Authorize this machine"
echo "3. Copy the auth code if needed"
echo ""

# Check if we're in an interactive terminal
if [[ -t 0 ]]; then
    read -p "Run the authentication command now? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        eval $TS_CMD
        log_success "Tailscale is configured!"
    fi
else
    log_info "Run the command above manually to authenticate."
fi

# After authentication, show info
echo ""
echo -e "${YELLOW}=================================="
echo "Next Steps"
echo "==================================${NC}"
echo ""
echo "1. Get your Tailscale IP address:"
echo -e "${GREEN}   tailscale ip -4${NC}"
echo ""
echo "2. Add this IP to your iOS Termius configuration"
echo ""
echo "3. Test SSH connection from your iPhone"
echo ""
echo "4. Update the vm-lifecycle scripts with your Tailscale IP/hostname"
echo ""

# Optional: Configure nftables for additional security
log_info "Note: Consider configuring nftables for additional security layers."
log_info "See ../ssh/ for firewall configuration scripts."
