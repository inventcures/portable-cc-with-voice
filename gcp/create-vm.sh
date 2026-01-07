#!/bin/bash
# Create Google Cloud VM instance for Portable Claude Code
#
# Usage: ./create-vm.sh [PROJECT_ID] [ZONE] [INSTANCE_NAME]
#
# Creates an e2-medium VM with Ubuntu 24.04, no public IP,
# and cloud-init to install base dependencies.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_ID="${1:-portable-cc-dev}"
ZONE="${2:-us-central1-a}"
INSTANCE_NAME="${3:-portable-cc-dev}"
MACHINE_TYPE="${MACHINE_TYPE:-e2-medium}"
BOOT_DISK_SIZE="${BOOT_DISK_SIZE:-30GB}"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLOUD_CONFIG_FILE="$SCRIPT_DIR/cloud-config.yaml"

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
echo "Portable CC - Create VM"
echo "=================================="
echo -e "${NC}"
echo "Project:     $PROJECT_ID"
echo "Zone:        $ZONE"
echo "Instance:    $INSTANCE_NAME"
echo "Machine:     $MACHINE_TYPE"
echo "Disk:        $BOOT_DISK_SIZE"
echo ""

# Verify cloud-config exists
if [[ ! -f "$CLOUD_CONFIG_FILE" ]]; then
    log_error "cloud-config.yaml not found at: $CLOUD_CONFIG_FILE"
    exit 1
fi

# Check if instance already exists
log_info "Checking if instance already exists..."
if gcloud compute instances describe "$INSTANCE_NAME" --zone="$ZONE" --project="$PROJECT_ID" &> /dev/null; then
    log_warning "Instance '$INSTANCE_NAME' already exists."
    read -p "Delete and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deleting existing instance..."
        gcloud compute instances delete "$INSTANCE_NAME" \
            --zone="$ZONE" \
            --project="$PROJECT_ID" \
            --quiet
    else
        log_info "Keeping existing instance. Exiting."
        exit 0
    fi
fi

# Set active project
log_info "Setting active project..."
gcloud config set project "$PROJECT_ID"

# Create the VM instance
log_info "Creating VM instance..."
log_info "This may take 1-2 minutes..."

gcloud compute instances create "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --network-interface=no-address,network-tier=STANDARD \
    --maintenance-policy=TERMINATE \
    --provisioning-model=STANDARD \
    --service-account="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com" \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --create-disk=boot=yes,device-name="$INSTANCE_NAME",image=projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20250101,mode=rw,size=$BOOT_DISK_SIZE,type=projects/$PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=portable-cc=true \
    --metadata-from-file=user-data="$CLOUD_CONFIG_FILE" \
    --metadata=enable-osconfig=TRUE

log_success "VM instance created!"

# Get instance details
log_info "Getting instance details..."
gcloud compute instances describe "$INSTANCE_NAME" \
    --zone="$ZONE" \
    --project="$PROJECT_ID" \
    --format="value(name,status,machineType)" | while read -r line; do
    echo "  $line"
done

echo ""
echo -e "${GREEN}=================================="
echo "VM Created Successfully!"
echo "==================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Wait for the VM to fully boot (30-60 seconds)"
echo "2. Connect to the VM console to get Tailscale auth URL:"
echo "   gcloud compute connect-to-serial-port $INSTANCE_NAME --zone=$ZONE --project=$PROJECT_ID --port=1"
echo ""
echo "3. Install Tailscale:"
echo "   sudo tailscale up"
echo ""
echo "4. Once Tailscale is connected, get the Tailscale IP:"
echo "   tailscale ip -4"
echo ""
echo "5. Update vm-lifecycle/vm-start with your Tailscale IP/hostname"
echo "6. Connect via SSH:"
echo "   ssh ubuntu@<tailscale-ip>"
echo ""
echo -e "${YELLOW}Cost Estimate:${NC}"
echo "e2-medium: ~\$0.05/hour (~\$36/month if running 24/7)"
echo "With start/stop workflow: ~\$10-30/month depending on usage"
echo ""
