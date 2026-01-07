#!/bin/bash
# Claude Code Push Notification Hook
#
# This script sends push notifications to your iOS device
# when Claude Code needs user input (via AskUserQuestion).
#
# Integrates with ntfy.sh for push notifications.
#
# Setup:
# 1. Place in ~/.claude/hooks/notify.sh
# 2. Make executable: chmod +x ~/.claude/hooks/notify.sh
# 3. Configure in ~/.claude/settings.json
# 4. Set your ntfy topic via environment or edit below

set -euo pipefail

# ============================================
# Configuration
# ============================================

# ntfy.sh topic - use a random/unique name for privacy
# Set via environment: export NTFY_TOPIC="your-secret-topic"
NTFY_TOPIC="${NTFY_TOPIC:-}"

# ntfy.sh server (default: https://ntfy.sh)
# For self-hosted: export NTFY_SERVER="https://your-ntfy-server.com"
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"

# Authentication (optional)
# For private topics: export NTFY_TOKEN="your-token"
NTFY_TOKEN="${NTFY_TOKEN:-}"

# Notification priority (default: high)
# Options: min, low, default, high, urgent
NTFY_PRIORITY="${NTFY_PRIORITY:-high}"

# ============================================
# Functions
# ============================================

send_notification() {
    local title="$1"
    local message="$2"

    # Build curl command
    local curl_cmd="curl -s -X POST '${NTFY_SERVER}/${NTFY_TOPIC}' \
        -H 'Title: ${title}' \
        -H 'Priority: ${NTFY_PRIORITY}' \
        -H 'Tags: Claude,laptop'"

    # Add authentication if token is set
    if [[ -n "$NTFY_TOKEN" ]]; then
        curl_cmd="${curl_cmd} -H 'Authorization: Bearer ${NTFY_TOKEN}'"
    fi

    # Add message body
    curl_cmd="${curl_cmd} -d '${message}'"

    # Send notification
    eval "$curl_cmd" > /dev/null 2>&1 || true
}

get_project_name() {
    # Try to get project name from git
    local git_root
    git_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

    if [[ -n "$git_root" ]]; then
        basename "$git_root"
    else
        # Fallback to current directory name
        basename "$(pwd)"
    fi
}

# ============================================
# Main
# ============================================

# Read event data from stdin
EVENT_DATA=$(cat)

# Check if this is an AskUserQuestion event
TOOL_NAME=$(echo "$EVENT_DATA" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

if [[ "$TOOL_NAME" != "AskUserQuestion" ]]; then
    # Not the event we're looking for
    exit 0
fi

# Check if topic is configured
if [[ -z "$NTFY_TOPIC" ]]; then
    # No topic configured, skip notification silently
    # You could log this for debugging:
    # echo "[$(date)] NTFY_TOPIC not set, skipping notification" >> ~/.claude/hooks/notify.log
    exit 0
fi

# Extract the question from the event data
QUESTION=$(echo "$EVENT_DATA" | jq -r '.tool_input.questions[0].question // "Claude needs input"' 2>/dev/null || echo "Claude needs input")

# Get project name
PROJECT_NAME=$(get_project_name)

# Send notification
send_notification "Claude: $PROJECT_NAME" "$QUESTION"

# Optional: Log notification for debugging
# echo "[$(date)] Sent notification for $PROJECT_NAME" >> ~/.claude/hooks/notify.log

exit 0
