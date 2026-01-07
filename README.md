# Portable Claude Code on iOS

Invoke Claude Code from your iPhone for development work anywhere. Based on [Claude Code On-The-Go](https://granda.org/en/2026/01/02/claude-code-on-the-go/), adapted for Google Cloud with voice input support.

## Quick Start

1. **Set up Google Cloud VM** (~5 minutes)
   ```bash
   ./gcp/setup-gcp.sh
   ./gcp/create-vm.sh
   ```

2. **Configure Tailscale** (~2 minutes)
   ```bash
   # On the VM
   sudo ./tailscale/install.sh
   ```

3. **Set up iOS apps** (~5 minutes)
   - Install Termius (SSH client)
   - Install Tailscale (VPN)
   - Install ntfy (notifications)
   - Install Wispr Flow (voice input, optional)

4. **Connect and code**
   ```bash
   ./vm-lifecycle/vm-start
   ```

## What This Enables

- **Review PRs** while waiting for coffee
- **Kick off refactors** on the train
- **Fix bugs** from the couch
- **Get notified** when Claude needs input
- **Voice commands** for hands-free coding

## Architecture

```
iOS Device (iPhone)
├── Termius (SSH/Mosh)
├── Tailscale (VPN)
├── ntfy (notifications)
└── Wispr Flow (voice)
        ↓
Google Cloud VM
├── tmux (persistent sessions)
├── Claude Code CLI
└── Hook scripts
        ↓
Push Notifications
```

## Features

| Feature | Description |
|---------|-------------|
| **Cloud VM** | e2-medium on Google Cloud (~$0.05/hr) |
| **Secure Access** | Tailscale VPN only, no public SSH |
| **Session Persistence** | tmux survives network transitions |
| **Push Notifications** | Alerted when Claude needs input |
| **Voice Input** | Dictate commands via Wispr Flow |
| **Multi-Agent** | Run multiple Claude instances in parallel |
| **Cost Control** | Start/stop on demand, ~$10-30/month |

## Project Structure

```
portable-cc-with-voice/
├── gcp/              # Google Cloud setup scripts
├── tailscale/        # Tailscale installation and config
├── ssh/              # SSH hardening and key setup
├── vm-config/        # VM dependencies and Claude setup
├── vm-lifecycle/     # Start/stop/status scripts
├── ios-shortcuts/    # iOS Shortcuts and Cloud Function
├── tmux/             # tmux configuration and guides
├── notifications/    # Push notification hook setup
├── voice/            # Wispr Flow and Siri guides
├── worktrees/        # Git worktree management scripts
└── docs/             # Detailed specifications
```

## Setup Guide

### Phase 1: Google Cloud Infrastructure

1. **Prerequisites**
   - GCP account with billing enabled
   - gcloud CLI installed
   - Basic familiarity with command line

2. **Create GCP resources**
   ```bash
   cd gcp
   ./setup-gcp.sh [PROJECT_ID] [ZONE] [INSTANCE_NAME]
   ```

   This creates:
   - GCP project (or uses existing)
   - Service account with Compute Instance Admin role
   - Service account key JSON
   - Firewall rules

3. **Create VM instance**
   ```bash
   ./create-vm.sh
   ```

   Cost: ~$0.05/hour (~$36/month 24/7, $10-30/month with start/stop)

### Phase 2: Tailscale Integration

1. **Install Tailscale on VM**
   ```bash
   cd ../tailscale
   ./install.sh --ssh
   ```

2. **Install Tailscale on iOS**
   - Download from App Store
   - Sign in
   - Enable VPN
   - Note your VM's Tailscale IP

3. **Test SSH**
   ```bash
   ssh ubuntu@<tailscale-ip>
   ```

See [tailscale/ios-setup-guide.md](tailscale/ios-setup-guide.md) for details.

### Phase 3: VM Configuration

On the VM:

```bash
# Install dependencies
~/portable-cc-with-voice/vm-config/install-dependencies.sh

# Set up Claude Code
~/portable-cc-with-voice/vm-config/setup-claude-code.sh

# User environment
~/portable-cc-with-voice/vm-config/user-setup.sh
```

### Phase 4: VM Lifecycle Management

From your local machine:

```bash
cd vm-lifecycle

# Set environment variables
export GCP_PROJECT_ID="your-project-id"
export GCP_ZONE="us-central1-a"
export GCP_INSTANCE_NAME="portable-cc-dev"
export TAILSCALE_HOST="your-tailscale-ip"

# Start VM and connect
./vm-start

# Check status
./vm-status

# Stop VM when done
./vm-stop
```

### Phase 5: Push Notifications

1. **Choose ntfy topic**
   ```bash
   export NTFY_TOPIC="portable-cc-$(uuidgen)"
   ```

2. **Install hook**
   ```bash
   mkdir -p ~/.claude/hooks
   cp notifications/notify.sh ~/.claude/hooks/
   chmod +x ~/.claude/hooks/notify.sh
   ```

3. **Configure Claude Code**
   ```bash
   cp notifications/settings.json ~/.claude/
   ```

4. **Install ntfy iOS app**
   - Subscribe to your topic
   - Enable notifications
   - Test with curl

See [notifications/ntfy-setup-guide.md](notifications/ntfy-setup-guide.md) for details.

### Phase 6: Voice Input

1. **Install Wispr Flow**
   - Download from App Store
   - Enable as keyboard
   - Grant full access

2. **Use in Termius**
   - Switch to Wispr Flow keyboard
   - Tap microphone
   - Speak command
   - Switch back to execute

See [voice/wispr-setup-guide.md](voice/wispr-setup-guide.md) for details.

### Phase 7: iOS Shortcuts

Optional: Create shortcuts for quick VM control.

See [ios-shortcuts/README.md](ios-shortcuts/README.md) for:
- Start/Stop VM shortcuts
- Cloud Function deployment
- Status checking

## Daily Workflow

### Starting a Development Session

1. **Start VM** (iOS Shortcut or `./vm-start`)
2. **Wait** for notification confirming it's running
3. **Open Termius** and connect via Tailscale
4. **tmux auto-attaches** to your session
5. **Navigate** to project: `cd ~/Code/myproject`
6. **Run Claude**: `claude-code`

### Working with Claude

1. **Assign tasks** to Claude
2. **Pocket your phone** - Claude works independently
3. **Get notification** when Claude needs input
4. **Open Termius** and respond
5. **Repeat** until task is complete

### Using Voice Input

1. **Switch to Wispr Flow keyboard**
2. **Tap microphone** and dictate
3. **Review** transcribed text
4. **Press Enter** to send

Example voice commands:
- "create a function that fetches user data"
- "fix the typescript error on line forty-two"
- "run the tests and show me the results"

### Ending a Session

1. **Exit Claude** (Ctrl-D)
2. **Detach tmux** (C-a d)
3. **Stop VM** (iOS Shortcut or `./vm-stop`)

## tmux Quick Reference

| Command | Action |
|---------|--------|
| `C-a c` | Create new window |
| `C-a n` | Next window |
| `C-a p` | Previous window |
| `C-a 0-9` | Go to window by number |
| `C-a d` | Detach session |
| `C-a \|` | Split vertical |
| `C-a -` | Split horizontal |

See [tmux/quick-reference.md](tmux/quick-reference.md) for more.

## Multi-Agent Workflow

Run multiple Claude instances in parallel:

```
Window 1: main branch
Window 2: feature-auth
Window 3: feature-db
Window 4: code review
```

Use git worktrees to manage multiple features:

```bash
./worktrees/create-worktree.sh auth myproject
./worktrees/list-worktrees.sh
```

See [tmux/workflow-guide.md](tmux/workflow-guide.md) for details.

## Cost Management

| Instance Type | Cost/Hour | Cost/Month (24/7) |
|---------------|-----------|-------------------|
| e2-small | ~$0.027 | ~$20 |
| e2-medium | ~$0.050 | ~$36 |
| e2-standard-2 | ~$0.100 | ~$72 |

**With start/stop workflow**: ~$10-30/month depending on usage.

### Cost Control Tips

1. **Stop VM when not in use** (`./vm-stop`)
2. **Use iOS Shortcuts** for easy start/stop
3. **Set up GCP billing alerts**
4. **Monitor usage** regularly

## Security

| Threat | Mitigation |
|--------|------------|
| Unauthorized SSH | Tailscale-only network + key auth |
| VM cost runaway | Per-hour instance + manual control |
| Notification exposure | Private ntfy topic |
| GCP credential exposure | Service account with minimal scope |
| Code execution risks | Isolated VM, no production access |

See [docs/v0_specs.md](docs/v0_specs.md) for detailed security specifications.

## Troubleshooting

### VM won't start

- Check GCP console for errors
- Verify quota is not exceeded
- Check service account permissions

### Can't SSH via Tailscale

- Verify Tailscale is connected on both devices
- Check VM is running: `./vm-status`
- Verify Tailscale IP hasn't changed

### No push notifications

- Check ntfy topic matches
- Test with curl command
- Verify iOS notifications enabled
- Check Claude hook is executable

### mosh connection drops

- Switch to regular SSH
- Check network stability
- Try Blink Shell for better mosh support

## Requirements

### iOS Device
- iPhone (iOS 15+ recommended)
- Termius app (subscription required)
- Tailscale app (free)
- ntfy app (free)
- Wispr Flow (free tier, optional)

### Google Cloud
- GCP account with billing
- Service account with Compute Instance Admin role
- Compute Engine API enabled

### VM (Ubuntu 24.04)
- 2 vCPU, 4 GB RAM minimum
- 30 GB disk
- Tailscale installed
- Claude Code CLI installed

## Alternatives

| Component | Primary Alternative |
|-----------|---------------------|
| SSH Client | Blink Shell (better mosh) |
| Cloud Provider | Vultr (easier setup), AWS Lightsail |
| Notifications | Gotify (self-hosted), Pushover |
| Voice Input | Siri Dictation (built-in) |

## Contributing

This is a personal project, but suggestions and improvements are welcome!

## References

- [Claude Code On-The-Go](https://granda.org/en/2026/01/02/claude-code-on-the-go/) - Inspiration
- [Tailscale Documentation](https://tailscale.com/kb/)
- [ntfy.sh](https://ntfy.sh/) - Push notifications
- [Wispr Flow](https://wisprflow.ai/) - Voice input
- [Claude Code](https://github.com/anthropics/claude-code) - AI coding assistant

## License

MIT License - feel free to use and adapt for your own needs.

---

**Made with ❤️ for mobile developers everywhere**

Start coding from anywhere! 📱💻
