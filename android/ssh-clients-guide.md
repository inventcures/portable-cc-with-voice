# Android SSH Client Comparison Guide

Several SSH clients are available on Android. This guide compares the most popular options for use with Portable Claude Code.

## Quick Comparison

| Client | Price | mosh | Termux | Key Features | Best For |
|--------|-------|------|--------|--------------|----------|
| **Termux** | Free | ✅ | ✅ | Full terminal, packages | Power users, VM control |
| **JuiceSSH** | Free | ❌ | ❌ | Great UI, snippets | SSH sessions |
| **Termius** | Paid | ✅ | ❌ | Cross-platform sync | iPhone + Android |
| **ConnectBot** | Free | ❌ | ❌ | Open-source, lightweight | Simple SSH |
| **UserLAnd** | Free | ✅ | ✅ | Full Linux desktop | Desktop-like experience |

## Recommendation

For Portable Claude Code:

1. **Install Termux** (required) - for vm-lifecycle scripts and local tools
2. **Install JuiceSSH** or use Termux's SSH - for terminal sessions

## Detailed Comparisons

### Termux (Required)

**Pros:**
- Full Linux environment on Android
- Package management (apt/pkg)
- Can run vm-lifecycle scripts directly
- Supports mosh for resilient connections
- Can run tmux locally
- Free and open-source

**Cons:**
- Steeper learning curve
- Not optimized for SSH session management
- Keyboard can be cramped on phone

**Best For:** Running scripts, local operations, VM control

**Install:**
```bash
# F-Droid (recommended)
https://f-droid.org/packages/com.termux/

# Or GitHub Releases
https://github.com/termux/termux-app/releases
```

### JuiceSSH

**Pros:**
- Excellent UI for SSH connections
- Connection snippets (save hosts, ports, keys)
- Local terminal for quick commands
- Color-coded connections
- SFTP integration

**Cons:**
- No mosh support (use regular SSH)
- Ads in free version (can be removed)
- Can't run arbitrary scripts like Termux

**Best For:** Managed SSH sessions to VM

**Install:**
```
Play Store: https://play.google.com/store/apps/details/com.sonelli.juicessh
```

**Setup:**
1. Open JuiceSSH
2. Tap "Connections" → "+"
3. Fill in:
   - **Nickname**: portable-cc
   - **Type**: SSH
   - **Host**: <tailscale-ip>
   - **Port**: 22
   - **Authentication**: Use local authentication (key)
4. Tap "Local Authentication" → Generate key
5. Copy public key, add to VM's ~/.ssh/authorized_keys

### Termius

**Pros:**
- Cross-platform with iOS
- Syncs hosts and keys between devices
- Supports mosh
- Polished UI
- SFTP client

**Cons:**
- Subscription required (~$10-15/year)
- Free tier limits

**Best For:** Users who also use iOS - same app, same configs

**Install:**
```
Play Store: https://play.google.com/store/apps/details=com.termius.app
```

### ConnectBot

**Pros:**
- Completely free
- Open-source
- Lightweight
- Supports public key auth

**Cons:**
- UI is dated
- No mosh support
- Limited features compared to JuiceSSH

**Best For:** Simple SSH needs, privacy-focused users

**Install:**
```
Play Store: https://play.google.com/store/apps/details=com.connectbot
```

### UserLAnd (Alternative)

**Pros:**
- Full Linux desktop (VNC)
- Can run full desktop apps
- Supports mosh
- Termux-compatible

**Cons:**
- Heavy on resources
- More complex setup
- Overkill for terminal work

**Best For:** Users who need GUI apps on Android

## Setup: SSH Keys

### Option 1: Generate in Termux

```bash
# In Termux
pkg install openssh
ssh-keygen -t ed25519
cat ~/.ssh/id_ed25519.pub
# Copy and add to VM's ~/.ssh/authorized_keys
```

### Option 2: Generate in JuiceSSH

1. Open JuiceSSH
2. Tap "Identities" → "+"
3. Generate new key
4. Copy public key
5. Add to VM

### Option 3: Use Existing Key

```bash
# In Termux, copy existing key
# From your laptop:
scp ~/.ssh/id_ed25519.pub android@<phone-ip>:~/storage/shared/

# In Termux:
cat ~/storage/shared/id_ed25519.pub >> ~/.ssh/authorized_keys
# Copy to VM
ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@<tailscale-ip>
```

## mosh Support

### Termux (Recommended)

```bash
# Install mosh
pkg install mosh

# Connect via mosh
mosh ubuntu@<tailscale-ip>
```

### Termius

Has built-in mosh support.

### Others

JuiceSSH, ConnectBot: No mosh support.

## Connection Snippets

### JuiceSSH Snippet for VM

Create a snippet with:
- **Host**: your VM's Tailscale IP (changes, use hostname)
- **Port**: 22
- **User**: ubuntu
- **Initial Command**: `tmux attach -t main` (auto-attach!)

### Termux Aliases

```bash
# Add to ~/.bashrc or ~/.zshrc in Termux
alias cc-start='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-start'
alias cc-stop='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-stop'
alias cc-vm='mosh ubuntu@portable-cc-dev'
alias cc-status='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-status'
```

## Tailscale Hostnames

Instead of IPs, use Tailscale machine names:

1. In Tailscale app, find your VM
2. Note the "Machine name" (e.g., "portable-cc-dev")
3. Use this instead of IP: `ssh ubuntu@portable-cc-dev`

## Recommendations Summary

| Use Case | Recommended App |
|----------|----------------|
| **VM control** | Termux (run scripts) |
| **SSH sessions** | JuiceSSH or Termux SSH |
| **iPhone + Android** | Termius (syncs configs) |
| **Cross-platform tmux** | Termux or mosh client |
| **Minimal setup** | Termux only (everything built-in) |

## Troubleshooting

### "Connection refused"

- VM might be stopped: `./vm-status` to check
- Tailscale not connected: Open Tailscale app
- Wrong IP: Check Tailscale app for current IP

### "Host key verification failed"

```bash
# In Termux or JuiceSSH, remove old key
ssh-keygen -R <hostname-or-ip>
```

### mosh not working

```bash
# Ensure mosh is installed on VM and Android
# Check ports: mosh uses UDP 60000-61000
# On Android (Termux):
pkg install mosh
```

### JuiceSSH can't connect

- Check local authentication is enabled
- Verify key matches VM's authorized_keys
- Try manual connection first to debug
