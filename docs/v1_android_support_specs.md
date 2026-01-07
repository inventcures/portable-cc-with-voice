# Portable Claude Code on Android - v1 Specifications

## 1. Original Prompt

```
also plan & think hard about adding android support & wriyte detailed plan & specs
in @docs/v1_android_support_specs.md
```

### User Requirements (Clarified)

| Requirement | Choice |
|-------------|--------|
| **Primary Use** | Occasional use (backup to iPhone) |
| **Terminal** | Yes - use Termux for full Linux terminal |
| **Automation** | Tasker automation with manual control option |
| **Cross-Platform** | Must support switching between iOS and Android |

## 2. Plan Response

### Technical Architecture Summary

```
Android Device (Phone/Tablet)
├── Termux (full Linux terminal environment)
├── JuiceSSH (alternative SSH client)
├── Tailscale Android app (VPN)
├── ntfy Android app (push notifications)
├── Tasker (automation)
└── Gboard/Voice Access (voice input)
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
Android Push Notification (superior background handling vs iOS)
```

### Key Android Advantages

| Advantage | Description | Benefit Over iOS |
|-----------|-------------|------------------|
| **Termux** | Full Linux terminal on device | Run vm-lifecycle scripts locally without SSH |
| **Tasker** | Powerful automation platform | More flexible than iOS Shortcuts |
| **Free SSH clients** | Multiple free, open-source options | No subscription required |
| **Background handling** | Better app background persistence | More reliable connections |
| **File system** | Direct file access | Easier file transfers |
| **Cross-platform tmux** | Attach to same session from iOS or Android | Seamless device switching |

---

## 3. Detailed Specifications

### 3.1 System Overview

The Android support for Portable Claude Code enables the same cloud-based development workflow on Android devices as originally implemented for iOS. The system leverages Android's unique capability to run a full Linux environment (Termux) locally, enabling users to execute vm-lifecycle scripts, git operations, and other commands directly on their phone without requiring an SSH connection for basic operations.

**Key Value Proposition**: All the power of the iOS implementation, plus Termux's local Linux environment, Tasker's superior automation, and the freedom to switch seamlessly between iOS and Android devices while maintaining a single, persistent tmux session and Claude Code conversation.

**Use Case Positioning**: Android serves as a backup/complement to the primary iOS workflow. Users can start a Claude Code session on iPhone during their morning commute, receive push notifications on Android throughout the day, reconnect to review progress and respond to questions from their Android phone or tablet during lunch breaks, and then resume from either platform in the evening.

### 3.2 Cross-Platform Architecture

The Android implementation shares 100% of the backend infrastructure with the iOS implementation:

| Component | iOS | Android | Shared |
|-----------|-----|---------|--------|
| **GCP VM** | ✅ | ✅ | Same VM instance |
| **Tailscale Network** | ✅ | ✅ | Same tailnet |
| **tmux Sessions** | ✅ | ✅ | Can attach from either |
| **Claude Code** | ✅ | ✅ | Same instance |
| **ntfy Topic** | ✅ | ✅ | Same notifications |
| **vm-lifecycle Scripts** | Via iOS Shortcuts | Direct execution in Termux | Same scripts |
| **SSH Keys** | Termius managed | JuiceSSH/Termux managed | Can share or separate |

**Session Continuity**: A tmux session created from iPhone can be attached from Android, and vice versa. The session, including all running processes, command history, and Claude Code conversation, persists on the VM independent of the client device.

### 3.3 Component Specifications

#### 3.3.1 Android Client Stack

| Component | Primary Option | Alternative Options |
|-----------|----------------|---------------------|
| **SSH Client** | JuiceSSH (free, feature-rich) | Termius (cross-platform), ConnectBot (open-source), Termux (built-in mosh) |
| **Terminal** | Termux (full Linux) | JuiceSSH terminal (SSH-only) |
| **VPN Client** | Tailscale Android App | Same as iOS |
| **Voice Input** | Gboard Voice Typing (built-in) | Google Voice Access (hands-free), Futo Voice Input (privacy), FlorisBoard (open-source) |
| **Notifications** | ntfy Android App | Same as iOS (superior background handling) |
| **VM Control** | Tasker (automation) | Termux scripts (manual), GCP Console (web) |
| **File Management** | Termux:API, Material Files | Syncthing (sync), JuiceSSH SFTP |

**Android App Requirements**:
- **Termux**: Package manager (pkg), storage access, termux-api for advanced features
- **JuiceSSH**: SSH and mosh protocol support, key management, SFTP
- **Tailscale**: VPN connectivity, background connection maintenance
- **ntfy**: Push notification permissions, background execution whitelist
- **Tasker**: HTTP request actions, shell command execution, trigger profiles

#### 3.3.2 Termux Linux Environment

Termux provides Android with a genuine Linux terminal environment, a capability unique to Android and impossible on iOS:

| Capability | Description | Use Case |
|------------|-------------|----------|
| **Package Management** | pkg/apt repositories | Install git, vim, tmux, mosh locally |
| **Local Git** | Full git command on device | Clone repos, make commits without SSH |
| **Local tmux** | Run tmux on Android | Practice tmux workflows locally |
| **vm-lifecycle Scripts** | Execute directly from phone | Start/stop/check VM without laptop |
| **File System Access** | Direct Android storage access | Edit files in vim/nano locally |
| **Tasker Integration** | termux-api for automation | Trigger scripts from Tasker profiles |

**Termux Packages**:
- **Essential**: git, curl, jq, tmux, mosh, openssh
- **Development**: python, nodejs, build-essential
- **Enhanced**: neovim, ripgrep, fzf, bat, htop
- **Android Integration**: termux-api, termux-tools

**Storage Access**:
```bash
termux-setup-storage
# Creates ~/storage/shared for full Android filesystem access
```

#### 3.3.3 Tasker Automation

Tasker provides Android automation capabilities exceeding iOS Shortcuts:

| Profile Type | Trigger | Action | Use Case |
|--------------|---------|--------|----------|
| **Time-based** | 8:00 AM daily | Start VM via HTTP request | Morning VM ready |
| **Time-based** | 10:00 PM daily | Stop VM via HTTP request | Evening shutdown |
| **Location-based** | Enter work WiFi zone | Start VM + Open Termux | Auto-start on arrival |
| **Event-based** | ntfy notification received | Vibrate, flash screen | Alert for Claude questions |
| **Manual** | Home screen widget | Execute vm-start/vm-stop | On-demand control |

**Tasker Actions**:
1. **HTTP Request**: Call GCP Cloud Function for VM control
2. **Run Shell**: Execute Termux scripts directly
3. **Load App**: Launch Termux automatically
4. **Notify**: Show status notifications
5. **Variable Set/Get**: Store VM state

**Manual Fallback**: All automation includes manual control option via Termux scripts or GCP Console web interface.

#### 3.3.4 Voice Input Options

Android provides multiple voice input options, each with different strengths:

| Option | Price | Offline | Quality | Best For |
|--------|-------|---------|--------|----------|
| **Gboard Voice Typing** | Free | No | ⭐⭐⭐⭐ | General use, built-in |
| **Google Voice Access** | Free | Yes (partial) | ⭐⭐⭐⭐ | Complete hands-free control |
| **Futo Voice Input** | Paid | Yes | ⭐⭐⭐ | Privacy-focused dictation |
| **FlorisBoard** | Free | Yes | ⭐⭐⭐ | Open-source alternative |

**Comparison to iOS Wispr Flow**:
- **Wispr Flow**: Superior formatting, removes filler words, better technical term recognition
- **Gboard**: Basic transcription, requires manual cleanup, free and built-in
- **Voice Access**: Unique hands-free capability not available on iOS

**Punctuation Commands** (consistent across platforms):
- "period" / "dot" → .
- "comma" → ,
- "question mark" → ?
- "open parenthesis" → (
- "new line" → Enter

#### 3.3.5 Notifications

ntfy Android app provides superior background handling compared to iOS:

| Feature | Android | iOS | Winner |
|---------|---------|-----|--------|
| **Background delivery** | Better | Aggressive killing | Android |
| **Custom sounds** | Per-topic | Per-topic | Tie |
| **Widgets** | Yes | Yes | Tie |
| **Priority handling** | 5 levels | 5 levels | Tie |
| **Doze mode** | May affect | May affect | Tie (different mechanisms) |

**Notification Priorities**:
- `urgent`: Alert sound, heads-up banner
- `high`: Priority sound, vibration
- `default`: Normal notification
- `low`: Silent (maybe vibration)
- `min`: Silent, no vibration

### 3.4 Android-Specific Workflows

#### 3.4.1 Termux-Only Workflow

For operations that don't require the VM:

```bash
# In Termux, no SSH needed
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-status          # Check if VM is running
./vm-start           # Start VM (via Cloud Function API)
git status           # Local git operations
vim config.yaml      # Edit local files
```

**Advantage**: Can perform control operations without establishing SSH session.

#### 3.4.2 Full Session Workflow

Complete development session from Android:

```bash
# 1. Check VM status
./vm-status

# 2. Start if needed
./vm-start

# 3. Wait 30-60 seconds for boot

# 4. Connect via mosh
mosh ubuntu@portable-cc-dev tmux attach

# 5. Start Claude Code
claude-code

# 6. Work hands-free with voice input
```

#### 3.4.3 Cross-Platform Handoff Workflow

Switch between iOS and Android:

**On iPhone (Morning)**:
1. iOS Shortcut: Start VM
2. Termius: Connect, start Claude
3. Assign task
4. Lock phone

**On Android (Afternoon)**:
1. Termux: `mosh ubuntu@portable-cc-dev tmux attach`
2. **Same session!**
3. Review progress
4. Respond to questions

**Works bidirectionally** - start on either platform, continue on the other.

#### 3.4.4 Voice-Controlled Workflow

Complete hands-free with Google Voice Access:

1. Enable Voice Access
2. Say: "Open Termux"
3. Say: "Type mosh ubuntu at portable dash cc dash dev"
4. Say: "Tap enter"
5. Say: "Type claude-code"
6. Say: "Tap enter"
7. Say: "Type create function fetch user data"
8. Say: "Tap enter"

**True hands-free development** not possible on iOS.

#### 3.4.5 Emergency Fix Workflow

Quick bug fix from phone:

```bash
# In Termux or JuiceSSH
mosh ubuntu@portable-cc-dev

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

**All from your phone, anywhere**.

### 3.5 File Management

Android provides superior file management options:

| Method | Description | Best For |
|--------|-------------|----------|
| **Termux:API** | Direct Android storage access | Local file editing |
| **SCP** | Secure copy to/from VM | Individual files |
| **rsync** | Efficient sync for large transfers | Directories, projects |
| **Syncthing** | Continuous bidirectional sync | Active projects |
| **JuiceSSH SFTP** | Graphical file browser | Visual file management |
| **Material Files** | Android file manager app | General file browsing |

**Storage Locations**:
```bash
~/storage/shared/     # Internal storage
~/storage/downloads/  # Downloads folder
~/storage/documents/  # Documents
~/.                   # Termux home
```

### 3.6 Security Considerations

#### 3.6.1 SSH Key Management

| Approach | Description | Pros | Cons |
|----------|-------------|------|------|
| **Shared keys** | Same keys on iOS and Android | One key to manage | Key sharing required |
| **Separate keys** | Different keys per platform | Isolation | Multiple keys in authorized_keys |
| **Termius key sync** | Use Termius on both platforms | Automatic sync | Requires Termius subscription |

**Recommendation**: Separate keys for better isolation, or Termius if already subscribed.

#### 3.6.2 ntfy Topic Security

- Use non-guessable topic names (random strings)
- Consider ntfy authentication for production use
- Access tokens restrict who can publish to topic

```bash
# Generate secure topic name
openssl rand -hex 16
```

### 3.7 Cost Optimization

| Strategy | Implementation | Savings |
|----------|---------------|---------|
| **Manual VM lifecycle** | Start only when needed | ~$0.05/hour × hours used |
| **Scheduled shutdown** | Tasker 10 PM stop | Prevents overnight costs |
| **Auto-stop cron** | VM self-shutdown after inactivity | Safety net |
| **e2-small** | Use smaller instance for light work | ~40% cheaper |

**Daily cost examples**:
- 8-hour workday: ~$0.40
- 4-hour workday: ~$0.20
- Scheduled shutdown prevents forgotten VM costs

### 3.8 Troubleshooting Guide

#### 3.8.1 Common Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| **VM won't start** | Status stuck at "PROVISIONING" | Wait 2-3 minutes, check GCP Console |
| **Can't connect via mosh** | "Connection refused" | VM still booting, Tailscale not connected |
| **Termux permission denied** | Can't access storage | Run `termux-setup-storage` |
| **Tasker HTTP fails** | "Connection timeout" | Check API key, Cloud Function URL |
| **ntfy no notifications** | Don't receive alerts | Check topic name, app permissions |
| **tmux session not found** | "Session not found" | Session name mismatch, or doesn't exist |

#### 3.8.2 Debug Commands

```bash
# Check VM status
./vm-status

# Check Tailscale connection
tailscale status

# Test SSH without mosh
ssh ubuntu@portable-cc-dev

# Check tmux sessions
tmux ls

# Test ntfy
curl -X POST https://ntfy.sh/your-topic -d "Test"
```

### 3.9 Documentation Structure

```
android/
├── README.md                    # Android overview
├── ssh-clients-guide.md         # SSH client comparison (JuiceSSH, Termius, ConnectBot)
├── termux-setup-guide.md        # Termux installation and configuration
├── termux-packages.md           # Recommended packages list
├── tasker-profiles.md           # Tasker automation setup
├── tasker-import.xml            # Importable Tasker profiles
├── tasker-manual.md             # Manual VM control procedures
├── voice-input-guide.md         # Voice input options comparison
├── notifications-setup.md       # ntfy Android app configuration
├── workflows-guide.md           # Android-specific workflows
├── cross-platform.md            # iOS/Android switching guide
└── file-management.md           # File transfer and editing
```

### 3.10 Implementation Checklist

- [x] Create android/ directory structure
- [x] Document SSH client options (JuiceSSH, Termius, ConnectBot, Termux)
- [x] Create Termux setup guide
- [x] Document Termux packages
- [x] Create Tasker automation profiles
- [x] Create Tasker import XML
- [x] Document manual VM control procedures
- [x] Document voice input options
- [x] Document ntfy Android setup
- [x] Document Android-specific workflows
- [x] Create cross-platform switching guide
- [x] Document file management options
- [x] Create detailed specifications (this document)
- [ ] Update main README.md with Android section

### 3.11 Comparison Summary: iOS vs Android

| Aspect | iOS | Android | Winner |
|--------|-----|---------|--------|
| **SSH Client** | Termius (paid) | JuiceSSH (free), Termux | Android |
| **Terminal** | Termius only | Termux (full Linux) | Android |
| **Voice Input Formatting** | Wispr Flow (excellent) | Gboard (basic) | iOS |
| **Hands-Free Control** | Limited | Voice Access (full) | Android |
| **Automation** | iOS Shortcuts | Tasker (more powerful) | Android |
| **Background Apps** | Aggressive killing | Better handling | Android |
| **File Access** | Via SFTP | Direct filesystem | Android |
| **Free Options** | Limited | Many free apps | Android |
| **App Quality** | Polished | Variable | iOS |
| **Ecosystem** | Curated | Open | Preference |

**Overall Winner**: Android for capability and flexibility, iOS for polish and voice formatting.

**Best Approach**: Use both! Start on iPhone for superior voice input, continue on Android for local Termux operations, switch platforms as needed.

---

## 4. Summary

Android support transforms Portable Claude Code from iOS-specific to truly cross-platform. The key differentiator is Termux—a full Linux terminal running locally on Android that enables:

1. **Local operations**: Run vm-lifecycle scripts, git, and other commands without SSH
2. **Superior automation**: Tasker exceeds iOS Shortcuts capabilities
3. **Free alternatives**: No subscription required for SSH clients
4. **Session continuity**: Attach to the same tmux session from iOS or Android
5. **Hands-free coding**: Google Voice Access enables complete voice control

The backend infrastructure remains unchanged—same GCP VM, same Tailscale network, same ntfy topic, same Claude Code instance. This ensures seamless cross-platform operation: start a session on iPhone during morning commute, receive notifications on Android throughout the day, reconnect from Android tablet during lunch, and resume from either platform in the evening.

Android serves as an excellent backup platform to iOS, providing redundancy and flexibility while maintaining full compatibility with the existing workflow. The combination of iOS (superior voice input via Wispr Flow) and Android (Termux Linux environment, Tasker automation) creates the ultimate mobile development setup.

---

**Document Version**: v1
**Last Updated**: 2026-01-07
**Status**: Complete
