# Portable Claude Code on iOS - v0 Specifications

## 1. Original Prompt

```
1. I WANT TO BE ABLE TO INVOKE CC ON THE GO FROM MY IOS RUNNING IPHONE

2. WANT TO IMPLEMENT ALL OF THE FEATURES IN

a. https://granda.org/en/2026/01/02/claude-code-on-the-go/
b. support for siri & wispr flow

3. Think deeply, self reflect & write a detailed plan & specs to @docs/v0_specs.md (mkdir -p if dne),
in addiiton to this promp & your repsonse (in the next turn), as is, at the top of the md in
1. prompt & 2. plan response section, following which write the plan & detailed specs in 3.
```

## 2. Plan Response

### User Requirements (Clarified)

| Requirement | Choice |
|-------------|--------|
| Architecture | Blog setup (Termius SSH/mosh + Tailscale VPN + Cloud VM + Push notifications) |
| Cloud Provider | Google Cloud (Compute Engine) |
| Voice Features | Voice input dictation + push notifications (mix of #2 and #3) |
| Use Case | Both personal and professional development |

### Technical Architecture Summary

```
iOS Device (iPhone)
├── Termius (SSH/Mosh client)
├── Wispr Flow (voice dictation keyboard)
├── Tailscale iOS app (VPN)
├── ntfy iOS app (push notifications)
└── iOS Shortcuts (VM control)
        ↓
Tailscale VPN (private network)
        ↓
Google Cloud VM (e2-medium, Ubuntu 24.04)
├── tmux (session persistence)
├── Claude Code CLI
└── Hook scripts (push notifications)
        ↓
ntfy.sh (push notification service)
        ↓
iOS Push Notification
```

---

## 3. Detailed Specifications

### 3.1 System Overview

The Portable Claude Code (CC) system enables developers to invoke and interact with Claude Code from an iOS device (iPhone) for development work anywhere. The system uses a cloud-based virtual machine accessed via SSH/mosh through a Tailscale VPN, with push notifications alerting the user when Claude requires input.

**Key Value Proposition**: Code from anywhere - review PRs while waiting for coffee, kick off refactors on the train, fix bugs from the couch.

### 3.2 Reference Architecture

Based on the blog post "Claude Code On-The-Go" with adaptations:

| Original Component | Adaptation | Rationale |
|-------------------|------------|-----------|
| Vultr vhf-8c-32gb | Google Cloud e2-medium | User preference, cost-effective |
| Poke webhook | ntfy.sh | More flexible, self-hostable option |
| Vultr API | GCP REST API | Cloud provider match |
| Termius only | Termius + Wispr Flow | Voice input support |

### 3.3 Component Specifications

#### 3.3.1 iOS Client Stack

| Component | Specification |
|-----------|---------------|
| **SSH Client** | Termius (primary), Blink Shell (mosh alternative) |
| **VPN Client** | Tailscale iOS App |
| **Voice Input** | Wispr Flow keyboard (primary), iOS native dictation (fallback) |
| **Notifications** | ntfy iOS App |
| **VM Control** | iOS Shortcuts with GCP REST API integration |

**iOS App Requirements**:
- Termius: SSH and mosh protocol support
- Tailscale: VPN connectivity, must remain connected in background
- Wispr Flow: Keyboard extension with full access
- ntfy: Push notification permissions enabled
- iOS Shortcuts: URL fetching capability, local variable storage

#### 3.3.2 Cloud Infrastructure

| Parameter | Specification |
|-----------|---------------|
| **Provider** | Google Cloud Platform (GCP) |
| **Service** | Compute Engine |
| **Instance Type** | e2-medium (1 vCPU, 4 GB RAM) |
| **Alternate** | e2-small (2 shared vCPU, 2 GB RAM) for lighter workloads |
| **Region** | us-central1 or us-west1 (based on user location) |
| **OS Image** | Ubuntu 24.04 LTS Minimal |
| **Disk** | 30 GB Standard Persistent Disk |
| **Network** | Tailscale-only (no public SSH) |
| **Cost** | ~$0.05/hour = $36/month 24/7, or $10-30/month with start/stop |

**VM Security Layers**:
1. GCP Firewall: Block all inbound from public IPs
2. GCP Firewall: Allow Tailscale coordination traffic only
3. VM Internal (nftables): Default deny, Tailscale interface only
4. SSH: Key-based authentication only, password auth disabled
5. Fail2ban: Brute-force protection

#### 3.3.3 Network Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS Device                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Termius SSH/Mosh Client                       │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │         mosh protocol (UDP 60000+)                  │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              │                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              Tailscale iOS App (VPN)                      │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │         WireGuard tunnel to Tailscale coord          │ │ │
│  │  └──────────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Tailscale WireGuard
                              │
┌─────────────────────────────────────────────────────────────────┐
│                      Tailscale Network                          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │  VM: portable-cc-dev (100.x.x.x)                          │ │
│  │  - Tailscale interface: tailscale0                        │ │
│  │  - SSH listening on Tailscale IP only                     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

#### 3.3.4 Session Persistence (tmux)

**Specification**:
- Software: tmux 3.3a+
- Auto-attach: Configured in `.zshrc`
- Session name: `main` (default), additional sessions for worktrees
- Prefix key: `C-a` (screen-compatible)

**iOS-Friendly Configuration**:
- Mouse support enabled
- Compact status bar (shows session name and time)
- Base index starts at 1
- Vi-style key bindings for navigation

**Shell Integration** (`~/.zshrc`):
```bash
if [[ -z "$TMUX" ]]; then
    tmux attach -t main 2>/dev/null || tmux new -s main
fi
```

#### 3.3.5 Claude Code Integration

**Claude Code Version**: Latest CLI

**Hook Configuration** (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": {
          "tool_name": "AskUserQuestion"
        },
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/notify.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

**Hook Script Specification** (`notify.sh`):
- Input: STDIN receives EVENT_DATA (JSON)
- Parse: Extract `tool_input.questions[0].question`
- Extract: Project name from git repository
- POST to ntfy.sh topic with:
  - Title: "Claude: {project_name}"
  - Priority: high
  - Body: The question text

#### 3.3.6 Push Notification Service

**Primary Choice**: ntfy.sh

| Feature | Specification |
|---------|---------------|
| **Service** | ntfy.sh (https://ntfy.sh) |
| **Deployment** | Cloud tier (free) or self-hosted |
| **Protocol** | HTTP POST |
| **Authentication** | Optional (for private topics) |
| **Topic Naming** | Random UUID for privacy |
| **iOS App** | ntfy from App Store |
| **Message Format** | Plain text or JSON |

**Alternative Services** (for future consideration):
- Gotify: Self-hosted, requires more setup
- Pushover: Paid, reliable
- Apprise: Multi-service aggregator

#### 3.3.7 Voice Input

**Primary**: Wispr Flow AI Voice Keyboard

| Feature | Specification |
|---------|---------------|
| **App** | Wispr Flow (App Store) |
| **Type** | Keyboard extension |
| **Capabilities** | Voice-to-text with formatting |
| **Offline** | Yes (iOS 26+) |
| **Cost** | Free tier available |
| **Setup** | Enable in Settings > General > Keyboard |

**Fallback**: iOS Native Dictation
- Activated by microphone key on keyboard
- No special app needed
- Basic transcription (less formatting)

**Siri Integration** (Future enhancement):
- Siri Shortcut: "Ask Claude"
- Dictate text
- Save to clipboard
- Open Termius
- User pastes and executes

#### 3.3.8 VM Lifecycle Management

**Script Specifications**:

**vm-start**:
```bash
#!/bin/bash
# Usage: vm-start [project_name]

# 1. Call GCP REST API to start instance
# 2. Poll for instance status "RUNNING"
# 3. Poll for Tailscale connectivity (SSH check)
# 4. Connect via mosh

# Environment variables required:
# - GCP_PROJECT_ID
# - GCP_ZONE
# - GCP_INSTANCE_NAME
# - TAILSCALE_IP or TAILSCALE_HOSTNAME
```

**vm-stop**:
```bash
#!/bin/bash
# Usage: vm-stop

# 1. Call GCP REST API to stop instance
# 2. Confirm "TERMINATED" status
```

**iOS Shortcut Specification**:
- **"Start Dev VM"** Shortcut:
  - Action: Get Contents of URL (POST)
  - URL: `https://compute.googleapis.com/compute/v1/projects/{PROJECT}/zones/{ZONE}/instances/{INSTANCE}/start`
  - Headers: Authorization (Bearer token), Content-Type: application/json
  - Output: Show confirmation dialog
  - Wait: Optional (poll for running status)

**GCP Authentication for iOS**:
- Option 1: OAuth 2.0 with refresh token stored in shortcut
- Option 2: Cloud Function wrapper with simple API key
- Option 3: Use Firebase Authentication for easier token management

#### 3.3.9 Multi-Worktree Support

**Git Worktree Pattern**:
```
~/Code/myproject/              # main branch
~/Code/myproject-feature-a/    # feature/a branch
~/Code/myproject-feature-b/    # feature/b branch
```

**Port Allocation Algorithm**:
```python
def allocate_ports(branch_name: str) -> tuple[int, int]:
    """Allocate deterministic ports based on branch name hash"""
    hash_val = sum(ord(c) for c in branch_name)
    web_port = 8001 + (hash_val % 99)
    api_port = 9001 + (hash_val % 99)
    return web_port, api_port
```

**tmux Window per Worktree**:
- Window 1: main (main branch)
- Window 2: feature-a
- Window 3: feature-b
- Each window: independent Claude Code session

### 3.4 Detailed File Specifications

#### 3.4.1 GCP Setup Scripts

**`gcp/setup-gcp.sh`**:
```bash
#!/bin/bash
# GCP Project and Service Account Setup
#
# Prerequisites:
# - gcloud CLI installed and authenticated
# - Active GCP account with billing enabled
#
# Creates:
# - GCP project (or uses existing)
# - Service account with Compute Instance Admin role
# - Service account key JSON
# - Firewall rules

set -euo pipefail

PROJECT_ID="${1:-portable-cc-dev}"
ZONE="${2:-us-central1-a}"
INSTANCE_NAME="${3:-portable-cc-dev}"

echo "Setting up GCP project: $PROJECT_ID"

# Create project
gcloud projects create "$PROJECT_ID" || echo "Project may already exist"

# Set as active
gcloud config set project "$PROJECT_ID"

# Create service account
SA_NAME="portable-cc-vm-controller"
SA_EMAIL="$SA_NAME@$PROJECT_ID.iam.gserviceaccount.com"

gcloud iam service-accounts create "$SA_NAME" \
    --display-name="Portable CC VM Controller"

# Assign roles
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/compute.instanceAdmin"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/iam.serviceAccountUser"

# Create key
gcloud iam service-accounts keys create "$HOME/gcp-key.json" \
    --iam-account="$SA_EMAIL"

echo "Key saved to $HOME/gcp-key.json"
echo "Keep this secure!"
```

**`gcp/create-vm.sh`**:
```bash
#!/bin/bash
# Create VM with cloud-init

set -euo pipefail

PROJECT_ID="${1:-portable-cc-dev}"
ZONE="${2:-us-central1-a}"
INSTANCE_NAME="${3:-portable-cc-dev}"

# Read cloud-config
CLOUD_INIT=$(cat gcp/cloud-config.yaml | base64 -w 0)

gcloud compute instances create "$INSTANCE_NAME" \
    --project="$PROJECT_ID" \
    --zone="$ZONE" \
    --machine-type=e2-medium \
    --image-family=ubuntu-2404-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=30GB \
    --boot-disk-type=pd-standard \
    --network-interface=no-address \
    --metadata-from-file=user-data=gcp/cloud-config.yaml
```

**`gcp/cloud-config.yaml`**:
```yaml
#cloud-config

package_update: true
package_upgrade: true

packages:
  - curl
  - git
  - build-essential
  - nodejs
  - npm
  - python3
  - python3-pip
  - tmux
  - zsh
  - jq

runcmd:
  # Install Tailscale
  - curl -fsSL https://tailscale.com/install.sh | sh
  - echo "VM ready for Tailscale authentication"
```

#### 3.4.2 VM Lifecycle Scripts

**`vm-lifecycle/vm-start`**:
```bash
#!/bin/bash
# Start VM and connect

set -euo pipefail

# Configuration (source from env or config file)
GCP_PROJECT_ID="${GCP_PROJECT_ID:-portable-cc-dev}"
GCP_ZONE="${GCP_ZONE:-us-central1-a}"
GCP_INSTANCE_NAME="${GCP_INSTANCE_NAME:-portable-cc-dev}"
TAILSCALE_HOST="${TAILSCALE_HOST:-}"  # e.g., user@tailnet-name
SSH_USER="${SSH_USER:-ubuntu}"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting VM...${NC}"

# Start the VM using service account
gcloud compute instances start "$GCP_INSTANCE_NAME" \
    --zone="$GCP_ZONE" \
    --project="$GCP_PROJECT_ID" \
    --account="portable-cc-vm-controller@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

echo -e "${GREEN}VM started. Waiting for Tailscale...${NC}"

# Wait for Tailscale connection (max 60 seconds)
TIMEOUT=60
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
    if gcloud compute instances get-serial-port-output "$GCP_INSTANCE_NAME" \
        --zone="$GCP_ZONE" \
        --project="$GCP_PROJECT_ID" \
        --port=1 2>/dev/null | grep -q "Tailscale is"; then
        echo -e "${GREEN}Tailscale is ready!${NC}"
        break
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done

# Connect via mosh
echo -e "${YELLOW}Connecting via mosh...${NC}"
mosh "$SSH_USER@$TAILSCALE_HOST"
```

**`vm-lifecycle/vm-stop`**:
```bash
#!/bin/bash
# Stop VM

set -euo pipefail

GCP_PROJECT_ID="${GCP_PROJECT_ID:-portable-cc-dev}"
GCP_ZONE="${GCP_ZONE:-us-central1-a}"
GCP_INSTANCE_NAME="${GCP_INSTANCE_NAME:-portable-cc-dev}"

echo "Stopping VM..."
gcloud compute instances stop "$GCP_INSTANCE_NAME" \
    --zone="$GCP_ZONE" \
    --project="$GCP_PROJECT_ID"

echo "VM stopped."
```

#### 3.4.3 Notification Hook

**`notifications/notify.sh`**:
```bash
#!/bin/bash
# Claude Code PreToolUse hook for push notifications
#
# Sends notifications to iOS when Claude needs user input

set -euo pipefail

# Configuration
NTFY_TOPIC="${NTFY_TOPIC:-your-secret-topic-here}"
NTFY_SERVER="${NTFY_SERVER:-https://ntfy.sh}"

# Read event data from stdin
EVENT_DATA=$(cat)

# Check if this is an AskUserQuestion event
TOOL_NAME=$(echo "$EVENT_DATA" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" != "AskUserQuestion" ]; then
    exit 0
fi

# Extract the question
QUESTION=$(echo "$EVENT_DATA" | jq -r '.tool_input.questions[0].question // "Claude needs input"')

# Get project name from current directory
PROJECT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -n "$PROJECT_DIR" ]; then
    PROJECT_NAME=$(basename "$PROJECT_DIR")
else
    PROJECT_NAME="unknown"
fi

# Send notification
curl -s -X POST "$NTFY_SERVER/$NTFY_TOPIC" \
    -H "Title: Claude: $PROJECT_NAME" \
    -H "Priority: high" \
    -H "Tags: Claude,robot" \
    -d "Claude needs input: $QUESTION"

exit 0
```

**`notifications/settings.json`**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": {
          "tool_name": "AskUserQuestion"
        },
        "hooks": [
          {
            "type": "command",
            "command": "~/portable-cc-with-voice/notifications/notify.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

#### 3.4.4 Tmux Configuration

**`tmux/.tmux.conf`**:
```bash
# tmux configuration for mobile Claude Code development

# Remap prefix from C-b to C-a
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# iOS-friendly settings
set -g mouse on
set -g status-interval 5
set -g base-index 1
setw -g pane-base-index 1

# Status bar - compact for mobile
set -g status-left '[#S] '
set -g status-right '%H:%M '
set -g status-left-length 20
set -g status-right-length 10

# Better pane splitting
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Vi-style keys
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

# Window navigation
bind c new-window -c "#{pane_current_path}"
bind n next-window
bind p previous-window
bind 0 select-window -t :10

# Easy renaming
bind , command-prompt -p "Window name:" "rename-window '%%'"

# Pane navigation (iOS keyboard friendly)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
```

**`tmux/zshrc-integration.sh`** (to be added to `.zshrc`):
```bash
# Portable CC - tmux auto-attach

if [[ -z "$TMUX" && -n "$SSH_CONNECTION" ]]; then
    # We're in SSH but not in tmux
    EXISTING_SESSIONS=$(tmux list-sessions 2>/dev/null)

    if [[ -n "$EXISTING_SESSIONS" ]]; then
        # Attach to existing session or show menu
        if echo "$EXISTING_SESSIONS" | grep -q "^main"; then
            tmux attach -t main
        else
            # Show session picker
            SESSION=$(echo "$EXISTING_SESSIONS" | fzf --height 10 | cut -d: -f1)
            if [[ -n "$SESSION" ]]; then
                tmux attach -t "$SESSION"
            fi
        fi
    else
        # Create new session
        tmux new -s main
    fi
fi
```

#### 3.4.5 Worktree Scripts

**`worktrees/create-worktree.sh`**:
```bash
#!/bin/bash
# Create a new git worktree with isolated port allocation

set -euo pipefail

FEATURE_NAME="${1:-}"
BASE_DIR="${BASE_DIR:-$HOME/Code}"

if [[ -z "$FEATURE_NAME" ]]; then
    echo "Usage: $0 <feature-name> [project-name]"
    exit 1
fi

PROJECT_NAME="${2:-$(basename "$(pwd)")}"
MAIN_PATH="$BASE_DIR/$PROJECT_NAME"
WORKTREE_PATH="$BASE_DIR/${PROJECT_NAME}-${FEATURE_NAME}"

# Check if main exists
if [[ ! -d "$MAIN_PATH" ]]; then
    echo "Error: Main project path not found: $MAIN_PATH"
    exit 1
fi

# Create worktree
git -C "$MAIN_PATH" worktree add "$WORKTREE_PATH" -b "feature/$FEATURE_NAME"

# Calculate port allocation (same algorithm from blog)
HASH_VAL=0
for (( i=0; i<${#FEATURE_NAME}; i++ )); do
    CHAR="${FEATURE_NAME:$i:1}"
    VAL=$(printf '%d' "'$CHAR")
    HASH_VAL=$((HASH_VAL + VAL))
done

WEB_PORT=$((8001 + (HASH_VAL % 99)))
API_PORT=$((9001 + (HASH_VAL % 99)))

# Create .env file
cat > "$WORKTREE_PATH/.env.ports" <<EOF
# Auto-generated ports for worktree: $FEATURE_NAME
WEB_PORT=$WEB_PORT
API_PORT=$API_PORT
EOF

echo "Created worktree: $WORKTREE_PATH"
echo "Ports: WEB=$WEB_PORT, API=$API_PORT"
echo "Branch: feature/$FEATURE_NAME"
```

**`worktrees/list-worktrees.sh`**:
```bash
#!/bin/bash
# List all worktrees and their ports

set -euo pipefail

BASE_DIR="${BASE_DIR:-$HOME/Code}"

echo "Worktrees:"
echo "----------"

for dir in "$BASE_DIR"/*; do
    if [[ -d "$dir" && -f "$dir/.git" ]]; then
        if [[ -f "$dir/.env.ports" ]]; then
            source "$dir/.env.ports"
            echo "$(basename "$dir"): WEB=${WEB_PORT:-N/A} API=${API_PORT:-N/A}"
        else
            echo "$(basename "$dir"): No ports configured"
        fi
    fi
done
```

#### 3.4.6 Voice Setup Guides

**`voice/wispr-setup-guide.md`**:
```markdown
# Wispr Flow Setup for Mobile Claude Code

## Installation

1. Download Wispr Flow from the App Store
2. Open the app and complete initial setup
3. Grant necessary permissions (microphone, full access)

## Enable as Keyboard

1. Go to iOS Settings > General > Keyboard > Keyboards
2. Tap "Add New Keyboard"
3. Select "Wispr Flow"
4. Tap "Wispr Flow" and enable "Allow Full Access"
5. Set "Allow Full Access" to On

## Using Wispr Flow in Termius

1. Open Termius and connect to your VM
2. Tap in the terminal input area
3. Tap the globe/icon to switch to Wispr Flow keyboard
4. Tap the microphone button
5. Speak your command or question
6. Wispr Flow transcribes and formats your speech
7. Switch back to regular keyboard
8. Press Enter to execute

## Tips

- Wispr Flow removes filler words (um, uh, like) automatically
- It understands programming terms and technical vocabulary
- Works offline on iOS 26+ for basic transcription
- Create custom snippets for common commands
```

### 3.5 API Specifications

#### 3.5.1 GCP Compute Engine REST API

**Start Instance**:
```
POST https://compute.googleapis.com/compute/v1/projects/{PROJECT}/zones/{ZONE}/instances/{INSTANCE}/start

Authorization: Bearer {ACCESS_TOKEN}
Content-Type: application/json
```

**Stop Instance**:
```
POST https://compute.googleapis.com/compute/v1/projects/{PROJECT}/zones/{ZONE}/instances/{INSTANCE}/stop

Authorization: Bearer {ACCESS_TOKEN}
Content-Type: application/json
```

**Get Instance Status**:
```
GET https://compute.googleapis.com/compute/v1/projects/{PROJECT}/zones/{ZONE}/instances/{INSTANCE}

Authorization: Bearer {ACCESS_TOKEN}
```

Response:
```json
{
  "status": "RUNNING" | "STOPPING" | "TERMINATED",
  "networkInterfaces": [...]
}
```

#### 3.5.2 ntfy.sh API

**Send Notification**:
```bash
POST https://ntfy.sh/{TOPIC}
Content-Type: text/plain

Message body here
```

**With Headers**:
```bash
POST https://ntfy.sh/{TOPIC}
Title: Claude: myproject
Priority: high
Tags: Claude,robot
Click: https://example.com

Claude needs input: What database should we use?
```

**Priority Levels**:
- `min` | `low` | `default` | `high` | `urgent`

**Authentication** (optional):
```bash
POST https://ntfy.sh/{TOPIC}
Authorization: Bearer {TOKEN}

Message
```

### 3.6 Security Specifications

#### 3.6.1 Network Security

| Layer | Control |
|-------|---------|
| GCP Firewall | Block all inbound from 0.0.0.0/0 |
| GCP Firewall | Allow Tailscale coordination (tailscale.com) |
| VM Firewall (nftables) | Allow tailscale0 interface only |
| SSH | Key-based only, password auth disabled |
| Fail2ban | Ban after 3 failed attempts |

#### 3.6.2 Access Control

| Resource | Access Control |
|----------|----------------|
| GCP VM | Service account key (stored locally) |
| SSH | Private key (Termius keychain) |
| Tailscale | User account (iOS Keychain) |
| ntfy | Private topic name (acts as password) |
| VM | No production credentials stored |

#### 3.6.3 Cost Controls

| Mechanism | Specification |
|-----------|---------------|
| Instance Type | e2-medium (not high-memory) |
| Billing Alert | $50/month cap |
| Auto-stop | Cron job stops after 12 hours |
| Monitoring | Daily uptime report |

### 3.7 Testing Specifications

#### 3.7.1 Test Cases

| Test Case | Expected Result |
|-----------|-----------------|
| VM start from iOS Shortcut | VM starts, push notification confirms |
| SSH via Tailscale | Connection succeeds, no password prompt |
| tmux auto-attach | Session attached automatically on login |
| Claude Code hook | Notification sent when Claude asks question |
| ntfy iOS notification | Push notification received with correct message |
| Wispr Flow dictation | Text appears in terminal, formatted correctly |
| Network transition | mosh survives WiFi to cellular switch |
| Multi-worktree ports | Different ports for different branches |
| VM stop from iOS Shortcut | VM stops within 30 seconds |

#### 3.7.2 Acceptance Criteria

1. Can start VM from iPhone home screen
2. Can connect via Termius within 2 minutes
3. Claude Code session persists across Termius close/reopen
4. Receive push notification when Claude needs input
5. Can dictate commands using Wispr Flow
6. Can run multiple Claude agents in parallel (different tmux windows)
7. Can stop VM from iPhone when done
8. Total monthly cost < $50 with normal usage

### 3.8 Deployment Checklist

#### Phase 1: Infrastructure (Day 1)
- [ ] Create GCP project
- [ ] Create service account with IAM roles
- [ ] Download service account key
- [ ] Create VM instance
- [ ] Configure GCP firewall rules
- [ ] Verify VM cannot be reached via public IP

#### Phase 2: Networking (Day 1)
- [ ] Install Tailscale on VM
- [ ] Authenticate Tailscale
- [ ] Install Tailscale on iOS
- [ ] Verify Tailscale connectivity
- [ ] Configure SSH key authentication
- [ ] Test SSH connection via Tailscale IP

#### Phase 3: Environment (Day 2)
- [ ] Install development dependencies
- [ ] Install Claude Code CLI
- [ ] Configure tmux
- [ ] Configure .zshrc auto-attach
- [ ] Test session persistence

#### Phase 4: iOS Integration (Day 2)
- [ ] Create vm-start script
- [ ] Create vm-stop script
- [ ] Build iOS Shortcut for VM control
- [ ] Test VM start/stop from iOS
- [ ] Install Termius and configure host

#### Phase 5: Notifications (Day 3)
- [ ] Create ntfy.sh topic (or self-host)
- [ ] Create notify.sh hook script
- [ ] Configure Claude Code settings
- [ ] Install ntfy iOS app
- [ ] Test notification flow

#### Phase 6: Voice Input (Day 3)
- [ ] Install Wispr Flow
- [ ] Enable as keyboard
- [ ] Test dictation in Termius
- [ ] Create voice command reference

#### Phase 7: Workflow (Day 4)
- [ ] Create worktree scripts
- [ ] Set up port allocation
- [ ] Document tmux workflow
- [ ] Create quick reference guide

### 3.9 Operational Procedures

#### 3.9.1 Starting a Development Session

1. Tap "Start Dev VM" iOS Shortcut
2. Wait for confirmation notification
3. Open Termius
4. Tap Tailscale host
5. Wait for tmux to auto-attach
6. Navigate to project directory
7. Run `claude-code`
8. Assign tmux window (C-a , rename)

#### 3.9.2 Responding to Claude Questions

1. Receive push notification from ntfy
2. Tap notification to open Termius (or manually open)
3. See Claude waiting for input
4. Switch to Wispr Flow keyboard
5. Tap microphone and dictate response
6. Switch back to regular keyboard
7. Press Enter
8. Lock phone, wait for next notification

#### 3.9.3 Ending a Session

1. Exit Claude Code (Ctrl-D or appropriate)
2. Exit tmux: `C-a d` (detach) or `exit` (close)
4. Close Termius
5. Tap "Stop Dev VM" iOS Shortcut
6. Wait for confirmation

#### 3.9.4 Troubleshooting

| Issue | Solution |
|-------|----------|
| VM won't start | Check GCP console, verify quota, check service account |
| Can't SSH to VM | Verify Tailscale connected, check VM is running |
| mosh connection drops | Switch to regular SSH, check network stability |
| No notifications | Verify ntfy topic, check Claude hook logs |
| Wispr Flow not working | Verify keyboard has full access, use Siri dictation fallback |
| Session lost | Check tmux still running: `tmux list-sessions` |
| High costs | Verify VM stopped, check for runaway processes |

### 3.10 Future Enhancements

| Feature | Description | Priority |
|---------|-------------|----------|
| Siri Shortcuts integration | "Hey Siri, ask Claude" | Medium |
| Auto VM shutdown | Stop after N hours of inactivity | High |
| Usage analytics | Track time/cost per session | Low |
| Voice output | Text-to-speech for Claude responses | Medium |
| Multi-VM support | Different VMs for different projects | Low |
| Git auto-sync | Auto-push worktree changes | Medium |
| Smart notifications | Bundle multiple questions | Low |

---

## 4. References

- [Claude Code On-The-Go (Blog Post)](https://granda.org/en/2026/01/02/claude-code-on-the-go/)
- [Google Cloud Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Tailscale Documentation](https://tailscale.com/kb/)
- [ntfy.sh Documentation](https://ntfy.sh/)
- [Wispr Flow](https://wisprflow.ai/)
- [Termius](https://termius.com/)
- [Claude Code Documentation](https://github.com/anthropics/claude-code)

---

## Appendix: Quick Reference

### iOS Apps Required

| App | Purpose |
|-----|---------|
| Termius | SSH/Mosh client |
| Tailscale | VPN client |
| ntfy | Push notifications |
| Wispr Flow | Voice dictation |

### tmux Keybindings (iOS-Friendly)

| Key | Action |
|-----|--------|
| `C-a c` | Create new window |
| `C-a n` | Next window |
| `C-a p` | Previous window |
| `C-a 0-9` | Jump to window |
| `C-a d` | Detach session |
| `C-a \|` | Split vertical |
| `C-a -` | Split horizontal |

### Estimated Costs (Monthly)

| Item | Cost |
|------|------|
| e2-medium VM | ~$36 (24/7) |
| e2-medium VM | ~$10-30 (start/stop) |
| Tailscale | Free (personal) |
| ntfy.sh | Free (self-hosted) |
| Termius | Subscription required |
| Wispr Flow | Free tier available |

**Total**: ~$10-80/month depending on Termius plan and VM usage
