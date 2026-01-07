#!/bin/bash
# GCP Project and Service Account Setup for Portable Claude Code on iOS
#
# Usage: ./setup-gcp.sh [PROJECT_ID] [ZONE] [INSTANCE_NAME]
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Active GCP account with billing enabled
#
# Creates:
# - GCP project (or uses existing)
# - Service account with Compute Instance Admin role
# - Service account key JSON
# - Firewall rules for secure access

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="${1:-portable-cc-dev}"
ZONE="${2:-us-central1-a}"
INSTANCE_NAME="${3:-portable-cc-dev}"
SA_NAME="portable-cc-vm-controller"

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

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    log_error "gcloud CLI not found. Please install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if authenticated
if ! gcloud auth list --filter="status:ACTIVE" --format="value(account)" 2>/dev/null | grep -q .; then
    log_error "Not authenticated with gcloud. Run: gcloud auth login"
    exit 1
fi

echo -e "${GREEN}"
echo "=================================="
echo "Portable CC - GCP Setup"
echo "=================================="
echo -e "${NC}"
echo "Project ID:  $PROJECT_ID"
echo "Zone:        $ZONE"
echo "Instance:    $INSTANCE_NAME"
echo ""

# Check if project exists
log_info "Checking if project '$PROJECT_ID' exists..."
if gcloud projects describe "$PROJECT_ID" &> /dev/null; then
    log_warning "Project '$PROJECT_ID' already exists. Using existing project."
else
    log_info "Creating new GCP project: $PROJECT_ID"
    if ! gcloud projects create "$PROJECT_ID"; then
        log_error "Failed to create project. You might need to create it manually in the console."
        log_info "Visit: https://console.cloud.google.com/projectcreate"
        exit 1
    fi
    log_success "Project created: $PROJECT_ID"
fi

# Set as active project
log_info "Setting active project..."
gcloud config set project "$PROJECT_ID"
log_success "Active project set to: $PROJECT_ID"

# Check if billing is enabled
log_info "Checking billing status..."
if ! gcloud alpha billing projects describe "$PROJECT_ID" --format="value(billingEnabled)" 2>/dev/null | grep -q "true"; then
    log_error "Billing is not enabled for this project."
    log_info "Enable billing at: https://console.cloud.google.com/billing/linkedaccount?project=$PROJECT_ID"
    exit 1
fi
log_success "Billing is enabled."

# Create service account
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

log_info "Checking if service account exists..."
if gcloud iam service-accounts describe "$SA_EMAIL" &> /dev/null; then
    log_warning "Service account '$SA_NAME' already exists."
else
    log_info "Creating service account: $SA_NAME"
    gcloud iam service-accounts create "$SA_NAME" \
        --display-name="Portable CC VM Controller" \
        --description="Service account for controlling portable Claude Code development VM"
    log_success "Service account created."
fi

# Assign IAM roles
log_info "Assigning IAM roles to service account..."

roles=(
    "roles/compute.instanceAdmin"
    "roles/iam.serviceAccountUser"
)

for role in "${roles[@]}"; do
    log_info "Adding role: $role"
    gcloud projects add-iam-policy-binding "$PROJECT_ID" \
        --member="serviceAccount:$SA_EMAIL" \
        --role="$role" \
        --condition=None 2>/dev/null || log_warning "Role $role may already be assigned"
done

log_success "IAM roles assigned."

# Create service account key
KEY_FILE="$HOME/gcp-key-${PROJECT_ID}.json"

if [[ -f "$KEY_FILE" ]]; then
    log_warning "Key file already exists: $KEY_FILE"
    read -p "Overwrite existing key? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Keeping existing key file."
    else
        rm -f "$KEY_FILE"
    fi
fi

if [[ ! -f "$KEY_FILE" ]]; then
    log_info "Creating service account key..."
    gcloud iam service-accounts keys create "$KEY_FILE" \
        --iam-account="$SA_EMAIL" \
        --key-type=TYPE_GOOGLE_CREDENTIALS_FILE
    chmod 600 "$KEY_FILE"
    log_success "Key saved to: $KEY_FILE"
    log_warning "Keep this file secure! Do not commit to version control."
fi

# Create firewall rules
NETWORK_TAG="portable-cc"

log_info "Creating firewall rules..."

# Allow Tailscale coordination (outbound)
log_info "Setting up firewall rules for Tailscale..."

# Create firewall rule to deny all inbound SSH from public
log_info "Creating firewall rule to block public SSH..."
gcloud compute firewall-rules create "deny-ssh-${PROJECT_ID}" \
    --project="$PROJECT_ID" \
    --description="Deny SSH from public internet" \
    --direction=INGRESS \
    --action=DENY \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 2>/dev/null || log_warning "Firewall rule may already exist."

log_success "Firewall rules configured."

# Summary
echo ""
echo -e "${GREEN}=================================="
echo "Setup Complete!"
echo "==================================${NC}"
echo ""
echo "Project ID:     $PROJECT_ID"
echo "Zone:           $ZONE"
echo "Instance Name:  $INSTANCE_NAME"
echo "Service Account: $SA_EMAIL"
echo "Key File:       $KEY_FILE"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Create the VM instance:"
echo "   ./gcp/create-vm.sh $PROJECT_ID $ZONE $INSTANCE_NAME"
echo ""
echo "2. Or use the gcloud key for authentication in scripts:"
echo "   export GOOGLE_APPLICATION_CREDENTIALS=\"$KEY_FILE\""
echo ""
echo -e "${YELLOW}Important Security Notes:${NC}"
echo "- The key file $KEY_FILE gives access to your GCP resources"
echo "- Never commit this file to version control"
echo "- The VM will have no public IP - access via Tailscale only"
echo ""
