# Android Support - Portable Claude Code

Use your Android device to invoke Claude Code from anywhere. This complements the iOS implementation with Android-specific tools and workflows.

## Quick Start

1. **Install Termux** - Full Linux terminal on Android
2. **Install Tailscale** - Secure VPN access
3. **Install ntfy** - Push notifications
4. **Install JuiceSSH or Termius** - SSH client
5. **Connect and code**

## Why Android?

Android offers unique advantages for mobile development:

| Feature | Advantage |
|---------|-----------|
| **Termux** | Full Linux environment - run tools locally! |
| **Free SSH** | JuiceSSH, ConnectBot - no subscription needed |
| **Tasker** | Powerful automation - more flexible than iOS Shortcuts |
| **Background** | Apps stay alive better than iOS |
| **File Access** | Direct file system access |
| **Cross-Platform** | Same VM, same tmux sessions - switch from iOS anytime |

## Architecture

```
Android Device
├── Termux (full Linux terminal)
├── JuiceSSH/Termius (SSH client)
├── Tailscale (VPN)
├── ntfy (notifications)
└── Tasker (automation)
        ↓
Tailscale VPN (private network)
        ↓
Google Cloud VM (shared with iOS)
├── tmux (persistent sessions)
├── Claude Code CLI
└── Hook scripts
        ↓
Push Notifications
```

## Key Difference from iOS: Termux

**Termux** is a game-changer:

```bash
# On Android, in Termux:
# You can run vm-lifecycle scripts directly!
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-start    # Start the VM from your phone!
./vm-status   # Check status
```

No laptop needed for VM control!

## Cross-Platform Compatibility

| Component | iOS | Android | Shared? |
|-----------|-----|---------|---------|
| VM | ✅ | ✅ | ✅ Same GCP VM |
| Tailscale | ✅ | ✅ | ✅ Same tailnet |
| ntfy topic | ✅ | ✅ | ✅ Same notifications |
| tmux sessions | ✅ | ✅ | ✅ Attach from either! |
| Claude hooks | ✅ | ✅ | ✅ Same hooks |

**Start a Claude session on iPhone, continue on Android!**

## Setup Guide

### 1. Install Termux (Required)

```bash
# F-Droid (recommended)
# https://f-droid.org/packages/com.termux/

# Or GitHub
# https://github.com/termux/termux-app/releases
```

See [termux-setup-guide.md](termux-setup-guide.md) for detailed setup.

### 2. Install Tailscale

```bash
# Play Store
# https://play.google.com/store/apps/details=com.tailscale.ipn
```

### 3. Install ntfy

```bash
# Play Store
# https://play.google.com/store/apps/details=com.ntfy.app
```

### 4. Install SSH Client

Choose one:
- **JuiceSSH** (free, powerful): https://play.google.com/store/apps/details=com.sonelli.juicessh
- **Termius** (paid, cross-platform): https://play.google.com/store/apps/details=com.termius.app
- **Or use Termux** with built-in OpenSSH

### 5. Configure

See individual guides:
- [SSH Clients Guide](ssh-clients-guide.md)
- [Termux Setup](termux-setup-guide.md)
- [Tasker Profiles](tasker-profiles.md)
- [Voice Input](voice-input-guide.md)
- [Workflows](workflows-guide.md)

## Quick Reference

### Start VM from Android (Termux)

```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle
export GCP_PROJECT_ID="your-project"
export GCP_ZONE="us-central1-a"
export GCP_INSTANCE_NAME="portable-cc-dev"
./vm-start
```

### Connect to VM

```bash
# In Termux (after VM is running)
ssh ubuntu@<tailscale-ip>

# Or use JuiceSSH/Termius
```

### Use Existing tmux Session

```bash
# Attach to session from iPhone
tmux attach -t main
```

## Workflow Example

1. **Morning on iPhone**: Start Claude session, assign task
2. **Commute**: Check progress via ntfy notifications
3. **At work**: Continue on desktop
4. **Lunch break on Android**: Respond to Claude, review progress
5. **Evening on iPhone**: Finish up

Same VM, same sessions, different device!

## Requirements

| Component | Minimum |
|-----------|---------|
| Android | 8.0+ (Android 10+ recommended) |
| RAM | 4GB+ for Termux + Claude |
| Storage | 1GB+ for Termux packages |
| Network | WiFi or mobile data |

## Cost

All Android apps mentioned:
- **Termux**: Free
- **Tailscale**: Free (personal tier)
- **ntfy**: Free (self-hosted or cloud)
- **JuiceSSH**: Free
- **Tasker**: ~$3.99 one-time

**Total**: $0-4 (vs iOS ~$10-15/year for Termius)

## Next Steps

1. Set up Termux: [termux-setup-guide.md](termux-setup-guide.md)
2. Configure SSH client: [ssh-clients-guide.md](ssh-clients-guide.md)
3. Set up Tasker: [tasker-profiles.md](tasker-profiles.md)
4. Learn workflows: [workflows-guide.md](workflows-guide.md)
