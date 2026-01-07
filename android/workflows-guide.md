# Android Workflows Guide

This guide covers Android-specific workflows for Portable Claude Code, leveraging Termux, Tasker, and other Android capabilities.

## Workflow Overview

| Workflow | Description | Android Advantage |
|----------|-------------|-------------------|
| **Termux-Only** | Run hooks/scripts locally | No SSH needed |
| **Hybrid** | Termux + VM | Lightweight local + heavy VM |
| **Cross-Platform** | Switch between iOS and Android | Attach to same tmux |
| **Quick Edit** | Edit files directly | Direct file access |
| **Voice-Controlled** | Hands-free operation | Voice Access |

## Workflow 1: Termux-Only (No VM Needed)

### When to Use

- Quick git operations
- Run vm-lifecycle scripts
- Edit local files
- Check VM status

### Steps

```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle

# Check VM status without connecting
./vm-status

# If stopped, start it
./vm-start

# Wait a minute, then connect via SSH
mosh ubuntu@portable-cc-dev
```

### Advantages

- No SSH session needed for control
- Can check status quickly
- Scripts run locally on phone
- Can be automated with Tasker

## Workflow 2: Full Session from Termux

### Complete Local Development

```bash
# In Termux
# 1. Check VM status
./vm-status

# 2. Start VM if needed
./vm-start

# 3. Wait 30-60 seconds for VM to start

# 4. Connect via mosh
mosh ubuntu@portable-cc-dev

# 5. tmux auto-attaches to existing session
# (Or create new one)
```

### Why This Works

1. **Termux has mosh**: Network-resilient SSH
2. **tmux persistence**: Survives network transitions
3. **Background capable**: Termux runs in background
4. **Same VM**: Shared with iOS setup

## Workflow 3: Cross-Platform Session

### Start on iPhone, Continue on Android

**On iPhone (Morning)**:
1. Start VM via iOS Shortcut
2. Open Termius
3. Run Claude Code
4. Assign task
5. Lock phone

**During Day**:
- Check ntfy notifications
- Respond when Claude asks questions

**On Android (Afternoon)**:
1. Open Termux
2. Run: `mosh ubuntu@portable-cc-dev`
3. Run: `tmux attach -t main`
4. **Same session continues!**
5. Check progress, respond to questions

### Why This Works

- **Same VM**: iPhone and Android connect to same GCP VM
- **Same Tailscale**: Same private network
- **Same tmux**: Session persists across devices
- **Same Claude**: Continuous conversation

## Workflow 4: Termux + JuiceSSH

### Hybrid Approach

Use Termux for control, JuiceSSH for sessions:

```bash
# In Termux: Control VM
./vm-start
./vm-status

# In JuiceSSH: Connect to VM
# Open JuiceSSH
# Tap your VM connection
# Connected via SSH (no mosh, but good UI)
```

### When to Use

- Prefer Termius UI for SSH
- Need connection snippets
- Want better key management
- Using JuiceSSH features (SFTP, tunnels)

## Workflow 5: Voice-Controlled Development

### Hands-Free Operation

1. **Enable Google Voice Access**
2. **Say**: "Open Termux"
3. **Say**: "Type c c space start" (or create voice command)
4. **Wait** for VM to start
5. **Say**: "Type mosh ubuntu at portable dash cc dash dev"
6. **Say**: "Tap enter"
7. **Connected!**

### Voice Command for Claude

Once connected:

1. **Say**: "Type claude-code"
2. **Say**: "Tap enter"
3. **Say**: "Type create function fetch user data"
4. **Say**: "Tap enter"

### Alternative: Voice Input in Terminal

1. In terminal, tap microphone icon
2. Speak command naturally
3. Review transcribed text
4. Send to Claude

See [voice-input-guide.md](voice-input-guide.md) for details.

## Workflow 6: Tasker Automation

### Automated VM Management

**Morning Routine** (Tasker):

1. Trigger: 8:00 AM
2. Check VM status
3. If stopped, start VM
4. Notify when ready

**Evening Shutdown** (Tasker):

1. Trigger: 10:00 PM
2. Stop VM
3. Notify: "VM stopped"

**WiFi-Based** (Tasker):

1. Trigger: Connect to work WiFi
2. Start VM
3. Open Termux automatically

See [tasker-profiles.md](tasker-profiles.md) for setup.

## Workflow 7: Quick Edit on Android

### Editing Files Directly

```bash
# In Termux, on your phone:
cd ~/storage/shared/myproject

# Or clone repo to phone storage
git clone https://github.com/you/project.git

# Edit files
vim main.py

# Git operations
git add .
git commit -m "Quick fix"
git push
```

### When to Use

- Quick fixes without SSH session
- Editing config files
- Reviewing changes
- Emergency fixes

## Workflow 8: File Transfer

### From Android to VM

**Method 1: Termux:API**

```bash
# In Termux
cp ~/storage/shared/file.txt ~/
scp file.txt ubuntu@portable-cc-dev:~/code/
```

**Method 2: JuiceSSH SFTP**

1. Open JuiceSSH
2. Tap connection → SFTP
3. Navigate files
4. Upload/download

**Method 3: Syncthing**

1. Install Syncthing on Android
2. Set up folder sync
3. Auto-sync files between phone and VM

See [file-management.md](file-management.md) for details.

## Workflow 9: Multi-Device Development

### Using Multiple Devices

```
Desktop (Home)     → Full development
iPhone (Commute)    → Review, respond
Android (Lunch)     → Quick checks, light edits
Laptop (Work)       → Main work
```

**All connect to same VM!**

### Handoff Checklist

**When switching devices:**

1. **Check VM status** on current device
2. **Detach tmux** if connected (Ctrl+B, D)
3. **On new device**:
   - Connect via SSH/mosh
   - Attach to tmux: `tmux attach -t main`
4. **Verify** you're in the right session

**Everything is where you left it!**

## Workflow 10: Emergency Fix

### Quick Fix from Phone

```bash
# In Termux or JuiceSSH
ssh ubuntu@portable-cc-dev

# Or with tmux
mosh ubuntu@portable-cc-dev tmux attach

# Navigate to project
cd ~/Code/myproject

# Quick fix
vim problematic_file.py

# Test
python test_quick.py

# Commit
git add .
git commit -m "Emergency fix"
git push
```

**All from your phone, anywhere!**

## Workflow Comparison: iOS vs Android

| Task | iOS | Android |
|------|-----|---------|
| Start VM | iOS Shortcut | Tasker or Termux script |
| Connect | Termius | JuiceSSH or Termux |
| Voice Input | Wispr Flow | Gboard or Voice Access |
| Run Scripts | Need SSH | Termux directly |
| Check Status | Need SSH | Termux directly |
| Automation | iOS Shortcuts | Tasker (more powerful) |

## Best Practices

### 1. Always Detach tmux

Before switching devices:

```bash
# In tmux
# Detach: Ctrl+B, D
# Not: Exit from tmux (which kills session)
```

### 2. Use Tailscale Names

Instead of IPs, use machine names:

```bash
ssh ubuntu@portable-cc-dev
```

The Tailscale app shows your VM's name.

### 3. Check Status Before Connecting

```bash
# In Termux
./vm-status

# Only connect if RUNNING
```

### 4. Stop VM When Done

```bash
# In Termux
./vm-stop

# Or use Tasker widget
```

### 5. Enable Background Apps

For reliable notifications:

- Add Termux to battery whitelist
- Add ntfy to battery whitelist
- Add Tasker to battery whitelist
- Disable aggressive battery optimization

## Common Scenarios

### Scenario 1: Start from iPhone, Continue on Android

1. **iPhone**: Start VM (iOS Shortcut)
2. **iPhone**: Connect via Termius, start Claude
3. **During day**: Check ntfy notifications
4. **Android (afternoon)**:
   - Termux: `./vm-status` (check if running)
   - JuiceSSH: Connect to VM
   - Termux: `mosh ubuntu@portable-cc-dev tmux attach`
5. **Same session!**

### Scenario 2: Quick Status Check

```bash
# In Termux, anywhere
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-status
```

**No SSH needed!**

### Scenario 3: Start VM from Android (No iPhone)

```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-start

# Wait for it to start
# Then connect with JuiceSSH or Termux SSH
```

**Everything from your phone!**

### Scenario 4: Late Night Coding

```bash
# In Termux
./vm-start

# Connect
mosh ubuntu@portable-cc-dev tmux attach

# Code away...

# When done, stop VM
./vm-stop
```

## Advanced: Termux Background Service

### Run Termux as Background Service

Using Termux:Boot or Tasker:

1. Termux:Boot (if available)
2. Run script on device boot
3. Maintain VM connection in background

**Use case**: Always-on VM for quick access

**Warning**: Battery drain!

## Next Steps

1. Set up Termux: [termux-setup-guide.md](termux-setup-guide.md)
2. Install SSH client: [ssh-clients-guide.md](ssh-clients-guide.md)
3. Configure Tasker: [tasker-profiles.md](tasker-profiles.md)
4. Learn cross-platform: [cross-platform.md](cross-platform.md)
5. Set up file management: [file-management.md](file-management.md)
