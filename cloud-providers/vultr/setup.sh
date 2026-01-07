#!/bin/bash
# Vultr Setup for Portable Claude Code
#
# Usage: ./setup.sh [API_KEY]
#
# Prerequisites:
# - Vultr account with API key
# - curl and jq installed
#
# Creates:
# - SSH key on Vultr
# - Stores configuration for use by other scripts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config.sh"

# Source the config
source "$CONFIG_FILE"

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
echo "Portable CC - Vultr Setup"
echo "=================================="
echo -e "${NC}"
echo "Provider:    $PROVIDER_NAME"
echo "Instance:    $INSTANCE_NAME"
echo "Region:      $REGION ($REGION_NAME)"
echo ""

# Check for API key
if [[ -z "${VULTR_API_KEY:-}" ]]; then
    if [[ -n "${1:-}" ]]; then
        export VULTR_API_KEY="$1"
    else
        echo "Enter your Vultr API key:"
        echo "(Get it from: https://my.vultr.com/settings/#settingsapi)"
        read -rs VULTR_API_KEY
        echo ""
    fi
fi

if [[ -z "$VULTR_API_KEY" ]]; then
    log_error "VULTR_API_KEY is required."
    echo "Export it or pass as argument:"
    echo "  export VULTR_API_KEY=your_key"
    echo "  ./setup.sh your_key"
    exit 1
fi

# Test API connection
log_info "Testing Vultr API connection..."
if ! curl -s -X GET \
    "${VULTR_API_BASE}/instances" \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    | jq -e '.' > /dev/null 2>&1; then
    log_error "Failed to connect to Vultr API. Check your API key."
    exit 1
fi
log_success "API connection successful."

# Generate SSH key if it doesn't exist
SSH_KEY_NAME="portable-cc-$(date +%s)"
SSH_PRIVATE_KEY="$HOME/.ssh/portable_cc_vultr"
SSH_PUBLIC_KEY="${SSH_PRIVATE_KEY}.pub"

if [[ ! -f "$SSH_PRIVATE_KEY" ]]; then
    log_info "Generating SSH key pair..."
    ssh-keygen -t ed25519 -f "$SSH_PRIVATE_KEY" -N "" -C "portable-cc@vultr"
    chmod 600 "$SSH_PRIVATE_KEY"
    chmod 644 "$SSH_PUBLIC_KEY"
    log_success "SSH key generated: $SSH_PRIVATE_KEY"
else
    log_warning "SSH key already exists: $SSH_PRIVATE_KEY"
fi

# Get public key content
SSH_PUBLIC_KEY_CONTENT=$(cat "$SSH_PUBLIC_KEY")

# Check if SSH key already exists on Vultr
log_info "Checking if SSH key exists on Vultr..."
EXISTING_KEYS=$(curl -s -X GET \
    "${VULTR_API_BASE}/ssh-keys" \
    -H "Authorization: Bearer ${VULTR_API_KEY}")

# Check if our key is already there
if echo "$EXISTING_KEYS" | jq -e ".ssh_keys[] | select(.name == \"${SSH_KEY_NAME}\")" > /dev/null 2>&1; then
    log_warning "SSH key '${SSH_KEY_NAME}' already exists on Vultr."
    SSH_KEY_ID=$(echo "$EXISTING_KEYS" | jq -r ".ssh_keys[] | select(.name == \"${SSH_KEY_NAME}\") | .id")
    log_info "Using existing key ID: $SSH_KEY_ID"
else
    # Upload SSH key to Vultr
    log_info "Uploading SSH key to Vultr..."
    RESPONSE=$(curl -s -X POST \
        "${VULTR_API_BASE}/ssh-keys" \
        -H "Authorization: Bearer ${VULTR_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"name\":\"${SSH_KEY_NAME}\",\"ssh_key\":\"${SSH_PUBLIC_KEY_CONTENT}\"}")

    if echo "$RESPONSE" | jq -e '.id' > /dev/null 2>&1; then
        SSH_KEY_ID=$(echo "$RESPONSE" | jq -r '.id')
        log_success "SSH key uploaded: $SSH_KEY_ID"
    else
        log_error "Failed to upload SSH key."
        echo "$RESPONSE"
        exit 1
    fi
fi

# Save configuration to a local env file
ENV_FILE="$HOME/.portable-cc-vultr.env"
cat > "$ENV_FILE" << EOF
# Vultr Configuration for Portable Claude Code
# Generated: $(date)

export CLOUD_PROVIDER=vultr
export VULTR_API_KEY="${VULTR_API_KEY}"
export VULTR_SSH_KEY_ID="${SSH_KEY_ID}"
export VULTR_INSTANCE_NAME="${INSTANCE_NAME}"
export VULTR_REGION="${REGION}"
export VULTR_PLAN="${PLAN}"
export VULTR_OS_ID="${OS_ID}"
EOF

chmod 600 "$ENV_FILE"

echo ""
echo -e "${GREEN}=================================="
echo "Vultr Setup Complete!"
echo "==================================${NC}"
echo ""
echo "SSH Key ID:  $SSH_KEY_ID"
echo "Config file: $ENV_FILE"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Source the config file in your shell:"
echo "   source $ENV_FILE"
echo ""
echo "2. Create the VM instance:"
echo "   ./cloud-providers/vultr/create-vm.sh"
echo ""
echo -e "${YELLOW}Cost Estimate:${NC}"
echo "vc2-2c-4gb: ~\$0.03/hour (~\$22/month if running 24/7)"
echo "With start/stop workflow: ~\$5-15/month depending on usage"
echo ""
echo -e "${YELLOW}Vultr Region Options:${NC}"
echo "  ewr  - New Jersey (default, good for US East)"
echo "  il   - Chicago"
echo "  fra  - Frankfurt (EU)"
echo "  ams  - Amsterdam (EU)"
echo "  lax  - Los Angeles (US West)"
echo "  sfo  - San Francisco (US West)"
echo ""
echo "Set region with: export VULTR_REGION=fra"
echo ""
