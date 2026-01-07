#!/bin/bash
# Unified Cloud Provider Setup for Portable Claude Code
#
# Usage: ./setup.sh [provider] [args...]
#
# Providers: gcp, vultr

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROVIDER="${1:-${CLOUD_PROVIDER:-gcp}}"
shift || true

# Source config to validate provider
source "$SCRIPT_DIR/config.sh"

case "$PROVIDER" in
    gcp)
        exec "$SCRIPT_DIR/gcp/setup.sh" "$@"
        ;;
    vultr)
        exec "$SCRIPT_DIR/vultr/setup.sh" "$@"
        ;;
    *)
        echo "Unknown provider: $PROVIDER"
        echo "Valid providers: gcp, vultr"
        echo ""
        echo "Usage:"
        echo "  ./setup.sh gcp     # Set up Google Cloud Platform"
        echo "  ./setup.sh vultr   # Set up Vultr"
        echo ""
        echo "Or set CLOUD_PROVIDER environment variable:"
        echo "  export CLOUD_PROVIDER=vultr"
        echo "  ./setup.sh"
        exit 1
        ;;
esac
