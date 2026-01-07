#!/bin/bash
# Tailscale Configuration Helper
#
# This script helps configure common Tailscale options
# for the Portable Claude Code VM.
#
# Usage: ./tailscale-up.sh [OPTIONS]

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
echo "Tailscale Configuration"
echo "=================================="
echo -e "${NC}"

# Check if Tailscale is installed
if ! command -v tailscale &> /dev/null; then
    log_error "Tailscale is not installed."
    log_info "Run ./install.sh first."
    exit 1
fi

# Check current status
log_info "Checking Tailscale status..."
if tailscale status &> /dev/null; then
    log_success "Tailscale is running."
    echo ""
    tailscale status --json | jq -r '.BackendState'
    echo ""
    echo "Tailscale IP:"
    tailscale ip -4 2>/dev/null || echo "  Not available"
    echo ""
else
    log_warning "Tailscale is not running or not authenticated."
    echo ""
    echo "To authenticate, run:"
    echo -e "${GREEN}  sudo tailscale up${NC}"
    echo ""
    exit 1
fi

# Show available options
echo ""
echo -e "${YELLOW}=================================="
echo "Configuration Options"
echo "==================================${NC}"
echo ""
echo "Current Tailscale status:"
tailscale status --peers --json | jq -r '.'
echo ""

# Check if SSH is enabled
if tailscale status --json | jq -e '.Self.Capabilities[] | select(. == "ssh")' > /dev/null; then
    log_success "Tailscale SSH is enabled."
else
    log_warning "Tailscale SSH is not enabled."
    echo "To enable SSH, run:"
    echo -e "${GREEN}  sudo tailscale up --ssh=11222${NC}"
fi

echo ""
echo "For more configuration options, see:"
echo "  https://tailscale.com/kb/1083/cli-options"
echo ""
