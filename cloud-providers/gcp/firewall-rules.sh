#!/bin/bash
# Configure GCP Firewall Rules for Portable Claude Code VM
#
# This script sets up firewall rules to block public SSH access
# and only allow access through Tailscale's private network.
#
# Usage: ./firewall-rules.sh [PROJECT_ID]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ID="${1:-portable-cc-dev}"

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

echo -e "${GREEN}=================================="
echo "Portable CC - Firewall Setup"
echo "==================================${NC}"
echo ""

# Set active project
log_info "Setting active project: $PROJECT_ID"
gcloud config set project "$PROJECT_ID"

# Rule 1: Deny SSH from public internet
log_info "Creating firewall rule to deny public SSH..."
if gcloud compute firewall-rules describe "deny-ssh-${PROJECT_ID}" --project="$PROJECT_ID" &> /dev/null; then
    log_warning "Firewall rule 'deny-ssh-${PROJECT_ID}' already exists."
else
    gcloud compute firewall-rules create "deny-ssh-${PROJECT_ID}" \
        --project="$PROJECT_ID" \
        --description="Deny SSH from public internet - use Tailscale only" \
        --direction=INGRESS \
        --action=DENY \
        --rules=tcp:22 \
        --source-ranges=0.0.0.0/0 \
        --priority=1000
    log_success "Created rule: deny-ssh-${PROJECT_ID}"
fi

# Rule 2: Allow Tailscale coordination traffic (outbound is typically allowed by default)
log_info "Tailscale coordination traffic uses outbound HTTPS - usually allowed by default."

# Summary
echo ""
echo -e "${GREEN}=================================="
echo "Firewall Rules Summary"
echo "==================================${NC}"
echo ""
gcloud compute firewall-rules list --project="$PROJECT_ID" --filter="name:deny-ssh-*" --format="table(name,direction,action,sourceRanges.list():label=SRC_RANGES)"
echo ""
echo -e "${YELLOW}Security Notes:${NC}"
echo "- Public SSH (port 22) is blocked from all IPs"
echo "- VM has no public IP address"
echo "- All access is through Tailscale's private network"
echo "- Tailscale provides authentication and encryption"
echo ""
