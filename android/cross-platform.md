# Cross-Platform Development: iOS and Android

This guide explains how to seamlessly switch between iOS and Android while using Portable Claude Code, ensuring continuous development sessions across devices.

## The Power of Cross-Platform

**Key Insight**: Your VM, tmux sessions, and Claude Code conversations persist across devices. Start coding on your iPhone during commute, continue on Android tablet during lunch, finish on desktop at home.

## What Works Across Platforms?

| Component | iOS | Android | Shared? |
|-----------|-----|---------|---------|
| GCP VM | ✅ | ✅ | ✅ Same VM |
| Tailscale Network | ✅ | ✅ | ✅ Same tailnet |
| tmux Sessions | ✅ | ✅ | ✅ Can attach from both |
| Claude Code | ✅ | ✅ | ✅ Same instance |
| ntfy Notifications | ✅ | ✅ | ✅ Same topic |
| vm-lifecycle Scripts | ❌ | ✅ | ✅ Work on both (via Termux) |
| SSH Keys | ✅ | ✅ | ✅ Can share keys |

## Platform-Specific Tools

| Task | iOS | Android |
|------|-----|---------|
| SSH Client | Termius | JuiceSSH, Termux |
| Terminal | Termius only | Termux (full Linux!) |
| Automation | iOS Shortcuts | Tasker |
| Voice Input | Wispr Flow, Siri | Gboard, Voice Access |
| VM Control | iOS Shortcuts | Tasker, Termux scripts |

## Workflow: Start on iOS, Continue on Android

### Morning Commute (iPhone)

1. **Start VM**: iOS Shortcut → "Start Dev VM"
2. **Connect**: Open Termius → Connect to `portable-cc-dev`
3. **Start Session**: `claude-code`
4. **Assign Task**: "Review and refactor auth module"
5. **Lock Phone**: Claude works in background

### During Day (Both Platforms)

1. **Receive ntfy notification**: "Claude: What naming convention?"
2. **Reply from either device**:
   - **iPhone**: Termius → Type response
   - **Android**: Termux → `mosh ubuntu@portable-cc-dev tmux attach`
3. **Claude continues**: Works on same session

### Afternoon (Android Tablet/Phone)

1. **Open Termux**
2. **Attach to session**:
   ```bash
   mosh ubuntu@portable-cc-dev tmux attach -t main
   ```
3. **Review progress**: See Claude's work
4. **Provide feedback**: Continue conversation

### Evening (Desktop/Laptop)

1. **SSH from computer**:
   ```bash
   ssh ubuntu@portable-cc-dev
   tmux attach -t main
   ```
2. **Merge completed work**: Review and commit
3. **Stop VM**: When done

## Workflow: Start on Android, Continue on iOS

### Start on Android

1. **Termux**: Check VM status
   ```bash
   cd ~/portable-cc-with-voice/vm-lifecycle
   ./vm-status
   ```
2. **Start if needed**:
   ```bash
   ./vm-start
   ```
3. **Connect**:
   ```bash
   mosh ubuntu@portable-cc-dev tmux attach
   ```
4. **Start Claude**: `claude-code`
5. **Set task**: "Implement new feature"

### Continue on iPhone

1. **Open Termius**
2. **Connect**: Tap your VM connection
3. **Attach to tmux**:
   ```bash
   tmux attach -t main
   ```
4. **Same session!**: Continue where you left off

## Session Persistence

### How tmux Enables Cross-Platform

tmux sessions live on the VM, not on your device:

```
┌─────────────────────────────────────────┐
│           GCP VM (portable-cc-dev)        │
│  ┌─────────────────────────────────────┐ │
│  │  tmux session "main"                │ │
│  │  - Running Claude Code              │ │
│  │  - Current working directory        │ │
│  │  - Command history                  │ │
│  │  - Open files                       │ │
│  └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
         ↑                ↑           ↑
         |                |           |
    iPhone (Termius)  Android (Termux)  Desktop (SSH)
```

**Any device can attach to the same session!**

### Attaching from Different Devices

```bash
# From iOS (Termius)
tmux attach -t main

# From Android (Termux/JuiceSSH)
tmux attach -t main

# From Desktop
tmux attach -t main
```

**All see the same thing!**

## Tailscale: The Universal Network

Tailscale connects all your devices to the same private network:

```
Your Tailscale Network (tailnet)
├── iPhone (Termius client)
├── Android Phone (Termux/JuiceSSH)
├── Android Tablet (Termux)
├── Laptop (SSH/mosh)
├── Desktop (SSH/mosh)
└── GCP VM: portable-cc-dev (server)
```

**Benefits**:
- Same hostname: `portable-cc-dev` from any device
- No public IP needed
- End-to-end encryption
- Works over any internet connection

## ntfy: Universal Notifications

Receive notifications on all devices:

### Subscribe on All Devices

**iPhone**:
1. Open ntfy app
2. Subscribe to: `your-secret-topic`
3. Enable notifications

**Android**:
1. Open ntfy app
2. Subscribe to: `same-topic`
3. Configure notification sound

**Result**: Claude's questions reach you on whichever device you're using!

## Key Sharing Across Platforms

### SSH Keys

Share SSH keys between iOS and Android:

**From iOS to Android**:
1. Export key from Termius (Settings → Keys → Export)
2. Send to Android (email, Syncthing, etc.)
3. Import in JuiceSSH or Termux

**Or generate separate keys** and add both to VM:
```bash
# On VM, ~/.ssh/authorized_keys
ssh-rsa AAAA... ios-device-key
ssh-rsa AAAA... android-device-key
```

### Environment Variables

Keep consistent across platforms:

**On VM** (`~/.bashrc` or `~/.zshrc`):
```bash
export NTFY_TOPIC="your-secret-topic"
export CLOUD_FUNCTION_URL="https://..."
export API_KEY="your-api-key"
```

**Works regardless of which device connects!**

## Common Scenarios

### Scenario 1: Commute Handoff

**Morning Train (iPhone)**:
1. iOS Shortcut: Start VM
2. Termius: Connect, start Claude
3. Assign task: "Refactor authentication"

**Arrive at Work (Desktop)**:
1. SSH to VM
2. `tmux attach -t main`
3. Review Claude's progress
4. Continue work

**Lunch Break (Android)**:
1. Termux: `mosh ubuntu@portable-cc-dev tmux attach`
2. Check ntfy notification: Claude asks question
3. Respond: "Use JWT tokens"
4. Lock phone, Claude continues

**Evening (Home)**:
1. Attach from any device
2. Review completed work
3. Test and commit

### Scenario 2: Emergency Fix from Android

**Situation**: Bug reported, iPhone at home

**On Android**:
1. Termux: `./vm-start` (if stopped)
2. Termux: `mosh ubuntu@portable-cc-dev tmux attach`
3. Review bug report
4. Ask Claude: "Fix authentication bug"
5. Monitor via ntfy
6. Push fix

**Same Claude session, same tmux, same work!**

### Scenario 3: Tablet Development

**Use Android tablet for larger screen**:
1. Termux with physical keyboard
2. Full tmux interface visible
3. Better for code review
4. Switch to iPhone when away

## Platform Preferences by Task

| Task | Preferred Platform | Reason |
|------|-------------------|--------|
| Quick status check | Android (Termux) | No SSH needed |
| Voice input | iOS (Wispr Flow) | Better formatting |
| Complex automation | Android (Tasker) | More powerful |
-| Casual coding | Android (Termux) | Full terminal |
| Professional work | Desktop | Full IDE |
| On-the-go | Either | Both work! |

## Troubleshooting

### Session Not Found

**Problem**: `tmux attach` says "session not found"

**Solutions**:
1. Check if session exists:
   ```bash
   tmux ls
   ```
2. If none exist, create new:
   ```bash
   tmux new -s main
   ```
3. If session on other device, detach first:
   - From device A: Ctrl+B, D
   - From device B: `tmux attach`

### Can't Connect to VM

**Problem**: Connection refused

**Check**:
1. VM running?
   ```bash
   # Android
   ./vm-status
   # iOS: Use GCP Console
   ```
2. Tailscale connected?
   - Open Tailscale app on device
   - Check for `portable-cc-dev`
3. Correct hostname?
   - Must match Tailscale machine name

### Notifications Not Received

**Problem**: Not getting ntfy notifications

**Check**:
1. Same topic on all devices?
2. App permissions (background, notifications)?
3. Internet connection?
4. Hook configured on VM?
   ```bash
   cat ~/.claude/settings.json
   ```

## Best Practices

### 1. Always Detach, Don't Exit

When switching devices:
- ✅ Detach: `Ctrl+B, D`
- ❌ Exit: Closes session

### 2. Use Consistent Session Names

```bash
# Main development session
tmux new -s main

# Testing session
tmux new -s test

# Attach to specific session
tmux attach -t main
```

### 3. Sync Environment Variables

Keep these consistent:
- `NTFY_TOPIC`
- `EDITOR`
- `PATH` (if using Termux)

### 4. Test Cross-Platform Before Relying

Test handoff workflow:
1. Start session on iPhone
2. Detach (Ctrl+B, D)
3. Attach from Android
4. Verify everything is there

### 5. Use Version Control

Commit before switching:
```bash
git add .
git commit -m "Work in progress"
```

Safe to switch devices even if something goes wrong.

## Advanced: Device-Specific Configurations

### iOS-Specific

**Wispr Flow Integration**:
```bash
# In tmux on iOS
# Use Wispr Flow for voice input
# Better formatting than Android alternatives
```

**iOS Shortcuts for VM Control**:
- Quick VM start/stop
- One-tap connection

### Android-Specific

**Termux Advantages**:
```bash
# Run vm-lifecycle scripts locally
./vm-status
./vm-start

# No SSH needed for control!
```

**Tasker Automation**:
- Location-based VM start
- WiFi-triggered connection
- Automated backup

## Quick Reference

### Attach Commands

```bash
# iOS (Termius)
tmux attach -t main

# Android (Termux/JuiceSSH)
tmux attach -t main

# Or auto-attach
mosh ubuntu@portable-cc-dev tmux attach
```

### Connection Commands

```bash
# iOS: Use Termius UI

# Android Termux
mosh ubuntu@portable-cc-dev

# Android JuiceSSH: Use UI

# Desktop
ssh ubuntu@portable-cc-dev
```

### Status Check

```bash
# Android (local)
./vm-status

# iOS: Use GCP Console or Shortcut
```

## Next Steps

1. Set up both iOS and Android clients
2. Test tmux handoff between devices
3. Configure ntfy on all platforms
4. Practice cross-platform workflow
5. Establish preferred device per task type

## Summary

**The beauty of cross-platform Portable Claude Code**:

- **Same VM**: Works from any device
- **Same Session**: tmux persists everywhere
- **Same Conversation**: Claude continues across devices
- **Same Notifications**: ntfy reaches you anywhere
- **Choose Platform**: Use what's best for the moment

Start on iPhone, continue on Android, finish on desktop. The session never ends!
