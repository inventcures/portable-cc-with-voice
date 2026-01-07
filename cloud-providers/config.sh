#!/bin/bash
# Cloud Provider Configuration for Portable Claude Code
#
# This file configures which cloud provider to use (gcp or vultr)
# Source this file in other scripts to get provider-specific settings

# Set your preferred provider here: "gcp" or "vultr"
CLOUD_PROVIDER="${CLOUD_PROVIDER:-gcp}"

# Provider-specific configuration
case "$CLOUD_PROVIDER" in
    gcp)
        # GCP Configuration
        export PROJECT_ID="${GCP_PROJECT_ID:-portable-cc-dev}"
        export ZONE="${GCP_ZONE:-us-central1-a}"
        export INSTANCE_NAME="${GCP_INSTANCE_NAME:-portable-cc-dev}"
        export MACHINE_TYPE="${GCP_MACHINE_TYPE:-e2-medium}"
        export BOOT_DISK_SIZE="${GCP_BOOT_DISK_SIZE:-30GB}"
        export SA_NAME="${GCP_SA_NAME:-portable-cc-vm-controller}"
        export IMAGE_FAMILY="ubuntu-2404-noble"
        export IMAGE_PROJECT="ubuntu-os-cloud"

        # Cost per hour (USD)
        export COST_PER_HOUR=0.05

        # Provider display name
        export PROVIDER_NAME="Google Cloud Platform"

        # API endpoint for VM control (Cloud Function)
        export CLOUD_FUNCTION_URL="${GCP_CLOUD_FUNCTION_URL:-}"
        export API_KEY="${GCP_API_KEY:-}"
        ;;

    vultr)
        # Vultr Configuration
        export VULTR_API_KEY="${VULTR_API_KEY:-}"
        export REGION="${VULTR_REGION:-ewr}"        # New Jersey (default)
        export INSTANCE_NAME="${VULTR_INSTANCE_NAME:-portable-cc-dev}"
        export PLAN="${VULTR_PLAN:-vc2-2c-4gb}"     # 2 vCPU, 4GB RAM
        export OS_ID="${VULTR_OS_ID:-1743}"         # Ubuntu 24.04 x64
        export SSH_KEY_ID="${VULTR_SSH_KEY_ID:-}"
        export SNAPSHOT_ID="${VULTR_SNAPSHOT_ID:-}"  # For boot from snapshot

        # Cost per hour (USD) - vc2-2c-4gb
        export COST_PER_HOUR=0.03

        # Provider display name
        export PROVIDER_NAME="Vultr"

        # Vultr API base URL
        export VULTR_API_BASE="https://api.vultr.com/v2"

        # Map region codes to display names
        case "$REGION" in
            ewr) export REGION_NAME="New Jersey" ;;
            nj)  export REGION_NAME="New Jersey" ;;
            il)  export REGION_NAME="Chicago" ;;
            fra) export REGION_NAME="Frankfurt" ;;
            ams) export REGION_NAME="Amsterdam" ;;
            lax) export REGION_NAME="Los Angeles" ;;
            sfo) export REGION_NAME="San Francisco" ;;
            mia) export REGION_NAME="Miami" ;;
            atl) export REGION_NAME="Atlanta" ;;
            dfw) export REGION_NAME="Dallas" ;;
            sea) export REGION_NAME="Seattle" ;;
            *)   export REGION_NAME="$REGION" ;;
        esac
        ;;

    *)
        echo "Error: Unknown cloud provider '$CLOUD_PROVIDER'"
        echo "Valid providers: gcp, vultr"
        echo "Set CLOUD_PROVIDER environment variable or edit config.sh"
        exit 1
        ;;
esac

export CLOUD_PROVIDER

# Common settings across providers
export TAILSCALE_HOSTNAME="${TAILSCALE_HOSTNAME:-portable-cc-dev}"
export VM_USER="${VM_USER:-ubuntu}"

# Tailscale settings
export TAILSCALE_NETWORK="${TAILSCALE_NETWORK:-}"
export TAILSCALE_AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"

# Notification settings
export NTFY_TOPIC="${NTFY_TOPIC:-}"
export NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"

# Output current configuration
show_config() {
    echo "Cloud Provider Configuration"
    echo "============================"
    echo "Provider:    $PROVIDER_NAME ($CLOUD_PROVIDER)"
    echo "Instance:    $INSTANCE_NAME"
    echo "Cost:        ~\$${COST_PER_HOUR}/hour (~\$$(echo "$COST_PER_HOUR * 730" | bc)/month 24/7)"
    echo ""

    case "$CLOUD_PROVIDER" in
        gcp)
            echo "GCP Settings:"
            echo "  Project:     $PROJECT_ID"
            echo "  Zone:        $ZONE"
            echo "  Machine:     $MACHINE_TYPE"
            echo "  Disk:        $BOOT_DISK_SIZE"
            ;;
        vultr)
            echo "Vultr Settings:"
            echo "  Region:      $REGION ($REGION_NAME)"
            echo "  Plan:        $PLAN"
            echo "  OS ID:       $OS_ID (Ubuntu 24.04)"
            ;;
    esac

    echo ""
    echo "Tailscale:"
    echo "  Hostname:    $TAILSCALE_HOSTNAME"
    echo ""
}

# Export a simple status string for scripts
get_status_string() {
    case "$CLOUD_PROVIDER" in
        gcp)
            echo "gcp:${PROJECT_ID}:${ZONE}:${INSTANCE_NAME}"
            ;;
        vultr)
            echo "vultr:${REGION}:${INSTANCE_NAME}"
            ;;
    esac
}

# If this script is run directly (not sourced), show config
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    show_config
fi
