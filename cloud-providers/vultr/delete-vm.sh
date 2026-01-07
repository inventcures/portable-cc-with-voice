#!/bin/bash
# Delete Vultr VM instance
#
# Usage: ./delete-vm.sh [INSTANCE_ID]

set -euo pipefail

# Colors
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

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

INSTANCE_ID="${1:-}"

if [[ -z "$INSTANCE_ID" ]]; then
    # Try to find instance by name
    log_info "Looking for instance: $INSTANCE_NAME..."
    INSTANCES=$(curl -s -X GET \
        "${VULTR_API_BASE}/instances" \
        -H "Authorization: Bearer ${VULTR_API_KEY}")

    INSTANCE_ID=$(echo "$INSTANCES" | jq -r ".instances[] | select(.label == \"${INSTANCE_NAME}\") | .id" 2>/dev/null || echo "")

    if [[ -z "$INSTANCE_ID" ]]; then
        log_error "No instance found with name: $INSTANCE_NAME"
        echo "Available instances:"
        echo "$INSTANCES" | jq -r '.instances[] | "  \(.label) - \(.id)"'
        exit 1
    fi
fi

log_info "Deleting instance: $INSTANCE_ID ($INSTANCE_NAME)"

read -p "Confirm deletion? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Deletion cancelled."
    exit 0
fi

RESPONSE=$(curl -s -X DELETE \
    "${VULTR_API_BASE}/instances/${INSTANCE_ID}" \
    -H "Authorization: Bearer ${VULTR_API_KEY}")

if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    log_error "Failed to delete instance."
    echo "$RESPONSE"
    exit 1
fi

log_success "Instance deleted: $INSTANCE_ID"
