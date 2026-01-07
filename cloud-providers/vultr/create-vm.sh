#!/bin/bash
# Create Vultr VM instance for Portable Claude Code
#
# Usage: ./create-vm.sh [REGION] [PLAN]
#
# Creates a VC2 instance with Ubuntu 24.04, no public IPv4 (optional),
# and cloud-init to install base dependencies.

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
CLOUD_CONFIG_FILE="$SCRIPT_DIR/cloud-config.yaml"

# Source the config
source "$CONFIG_FILE"

# Override with command line args
REGION="${1:-${VULTR_REGION}}"
PLAN="${2:-${VULTR_PLAN}}"

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

# Check for API key
if [[ -z "${VULTR_API_KEY:-}" ]]; then
    log_error "VULTR_API_KEY not set."
    echo "Run ./setup.sh first or export: export VULTR_API_KEY=your_key"
    exit 1
fi

# Check for SSH key
if [[ -z "${VULTR_SSH_KEY_ID:-}" ]]; then
    log_warning "VULTR_SSH_KEY_ID not set. Instance will use password authentication only."
    log_warning "Run ./setup.sh to configure SSH keys."
    SSH_KEY_ARG=""
else
    SSH_KEY_ARG="--ssh-key-id ${VULTR_SSH_KEY_ID}"
fi

echo -e "${GREEN}"
echo "=================================="
echo "Portable CC - Create Vultr VM"
echo "=================================="
echo -e "${NC}"
echo "Provider:    $PROVIDER_NAME"
echo "Region:      $REGION ($REGION_NAME)"
echo "Instance:    $INSTANCE_NAME"
echo "Plan:        $PLAN"
echo ""

# Vultr API base URL
API_BASE="${VULTR_API_BASE}"

# Check if instance already exists
log_info "Checking if instance already exists..."
EXISTING_INSTANCES=$(curl -s -X GET \
    "${API_BASE}/instances" \
    -H "Authorization: Bearer ${VULTR_API_KEY}")

INSTANCE_ID=$(echo "$EXISTING_INSTANCES" | jq -r ".instances[] | select(.label == \"${INSTANCE_NAME}\") | .id" 2>/dev/null || echo "")

if [[ -n "$INSTANCE_ID" ]]; then
    log_warning "Instance '$INSTANCE_NAME' already exists (ID: $INSTANCE_ID)."
    STATUS=$(echo "$EXISTING_INSTANCES" | jq -r ".instances[] | select(.label == \"${INSTANCE_NAME}\") | .status")
    log_info "Current status: $STATUS"
    read -p "Delete and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deleting existing instance..."
        curl -s -X DELETE \
            "${API_BASE}/instances/${INSTANCE_ID}" \
            -H "Authorization: Bearer ${VULTR_API_KEY}" > /dev/null

        # Wait for deletion
        log_info "Waiting for instance to be deleted..."
        for i in {1..30}; do
            sleep 1
            CHECK=$(curl -s -X GET \
                "${API_BASE}/instances/${INSTANCE_ID}" \
                -H "Authorization: Bearer ${VULTR_API_KEY}" 2>/dev/null || echo "deleted")
            if [[ "$CHECK" == *"error"* ]] || [[ "$CHECK" == *"Invalid API"* ]]; then
                break
            fi
        done
        log_success "Instance deleted."
    else
        log_info "Keeping existing instance. Exiting."
        exit 0
    fi
fi

# Read cloud-init config
if [[ ! -f "$CLOUD_CONFIG_FILE" ]]; then
    log_error "cloud-config.yaml not found at: $CLOUD_CONFIG_FILE"
    exit 1
fi

# Base64 encode the cloud-init config
CLOUD_INIT_BASE64=$(base64 -i "$CLOUD_CONFIG_FILE")

# Create the instance
log_info "Creating VM instance..."
log_info "This may take 1-2 minutes..."

# Build the create instance request
cat > /tmp/vultr-create.json << EOF
{
    "label": "${INSTANCE_NAME}",
    "region": "${REGION}",
    "plan": "${PLAN}",
    "os_id": ${OS_ID},
    "hostname": "${INSTANCE_NAME}",
    "activation_email": "",
    "sshkey_id": "${VULTR_SSH_KEY_ID:-}",
    "user_data": "${CLOUD_INIT_BASE64}",
    "enable_ipv6": true,
    "backups": "disabled",
    "ddos_protection": false,
    "tags": ["portable-cc"]
}
EOF

RESPONSE=$(curl -s -X POST \
    "${API_BASE}/instances" \
    -H "Authorization: Bearer ${VULTR_API_KEY}" \
    -H "Content-Type: application/json" \
    -d @/tmp/vultr-create.json)

rm -f /tmp/vultr-create.json

# Check for errors
if echo "$RESPONSE" | jq -e '.error' > /dev/null 2>&1; then
    log_error "Failed to create instance."
    echo "$RESPONSE" | jq -r '.error'
    exit 1
fi

INSTANCE_ID=$(echo "$RESPONSE" | jq -r '.instance.id')
INSTANCE_PASSWORD=$(echo "$RESPONSE" | jq -r '.instance.default_password')

log_success "VM instance created!"
log_info "Instance ID: $INSTANCE_ID"

# Wait for instance to be active
log_info "Waiting for instance to become active..."
for i in {1..120}; do
    sleep 2
    STATUS_RESPONSE=$(curl -s -X GET \
        "${API_BASE}/instances/${INSTANCE_ID}" \
        -H "Authorization: Bearer ${VULTR_API_KEY}")

    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.instance.status')
    MAIN_IP=$(echo "$STATUS_RESPONSE" | jq -r '.instance.main_ip')

    echo -ne "\r  Status: $STATUS | IP: $MAIN_IP | Progress: $i/120 "

    if [[ "$STATUS" == "active" ]]; then
        echo ""
        log_success "Instance is active!"
        break
    fi
done
echo ""

# Get instance details
log_info "Getting instance details..."
curl -s -X GET \
    "${API_BASE}/instances/${INSTANCE_ID}" \
    -H "Authorization: Bearer ${VULTR_API_KEY}" | jq -r '.instance | "  Label: \(.label)\n  ID: \(.id)\n  Status: \(.status)\n  IP: \(.main_ip)\n  Region: \(.region)\n  Plan: \(.plan)"'

echo ""
echo -e "${GREEN}=================================="
echo "VM Created Successfully!"
echo "==================================${NC}"
echo ""
echo -e "${YELLOW}Instance Details:${NC}"
echo "  ID:          $INSTANCE_ID"
echo "  Label:       $INSTANCE_NAME"
echo "  Main IP:     $MAIN_IP"

if [[ -n "$INSTANCE_PASSWORD" ]] && [[ "$INSTANCE_PASSWORD" != "null" ]]; then
    echo ""
    echo -e "${YELLOW}Root Password:${NC} $INSTANCE_PASSWORD"
    echo -e "${RED}Save this password! It won't be shown again.${NC}"
fi

echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Wait for the VM to fully boot (30-60 seconds)"
echo ""
echo "2. Connect to the VM to set up Tailscale:"
echo "   ssh root@$MAIN_IP"
echo ""
echo "3. Install Tailscale:"
echo "   curl -fsSL https://tailscale.com/install.sh | sh"
echo "   sudo tailscale up"
echo ""
echo "4. Get the Tailscale IP:"
echo "   tailscale ip -4"
echo ""
echo "5. Update vm-lifecycle scripts with your Tailscale hostname"
echo "6. Add SSH keys for ubuntu user:"
echo "   ssh-copy-id ubuntu@$MAIN_IP"
echo ""
echo -e "${YELLOW}Cost Estimate:${NC}"
echo "vc2-2c-4gb: ~\$0.03/hour (~\$22/month if running 24/7)"
echo "vc2-4c-8gb: ~\$0.05/hour (~\$37/month if running 24/7)"
echo "With start/stop workflow: ~\$5-15/month depending on usage"
echo ""
echo -e "${YELLOW}To destroy this instance later:${NC}"
echo "   ./cloud-providers/vultr/delete-vm.sh $INSTANCE_ID"
echo ""
