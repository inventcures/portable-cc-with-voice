# Termux Setup Guide for Portable Claude Code

Termux is a powerful terminal emulator for Android that provides a full Linux environment. This is essential for Android support in Portable Claude Code.

## What is Termux?

Termux is:
- A terminal emulator
- A Linux environment (not emulation!)
- A package manager (apt/pkg)
- Can run tmux, vim, git, curl, jq, and more
- Free and open-source

## Why Termux is Essential for Portable CC

1. **Run vm-lifecycle scripts** directly from your phone
2. **Local tmux** for session management
3. **SSH/mosh client** built-in
4. **Git operations** without opening a full session
5. **File editing** with vim/neovim

## Installation

### Step 1: Install Termux

**IMPORTANT**: Install from F-Droid, not Play Store (Play Store version is outdated).

```bash
# F-Droid (recommended)
https://f-droid.org/packages/com.termux/

# Or GitHub Releases
https://github.com/termux/termux-app/releases
```

### Step 2: Initial Setup

Open Termux and run:

```bash
# Update packages
pkg update && pkg upgrade

# Install essential tools
pkg install git curl jq nano vim tmux mosh openssh

# Set up storage access (for file transfer)
termux-setup-storage
```

### Step 3: Clone the Repository

```bash
# Clone portable-cc-with-voice
git clone https://github.com/inventcures/portable-cc-with-voice.git

# Or your fork
git clone https://github.com/<your-username>/portable-cc-with-voice.git

# Navigate to project
cd portable-cc-with-voice
```

### Step 4: Configure Environment

```bash
# Edit shell configuration
nano ~/.bashrc

# Add useful aliases
alias cc-start='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-start'
alias cc-stop='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-stop'
alias cc-status='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-status'
alias ll='ls -lah'
alias gs='git status'
```

### Step 5: Configure VM Environment Variables

```bash
# Add to ~/.bashrc or ~/.bashrc.termux
export GCP_PROJECT_ID="your-project-id"
export GCP_ZONE="us-central1-a"
export GCP_INSTANCE_NAME="portable-cc-dev"
export TAILSCALE_HOST="your-vm-tailscale-name"
export SSH_USER="ubuntu"
```

### Step 6: Configure Git

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

## Recommended Packages

### Core Development

```bash
pkg install git vim tmux curl jq wget
```

### SSH & Networking

```bash
pkg install openssh mosh
```

### Python

```bash
pkg install python
```

### Node.js (Optional)

```bash
pkg install nodejs npm
```

### Enhanced Tools

```bash
pkg install htop neovim ripgrep fzf bat
```

### Claude Code Support

```bash
pkg install python nodejs
# Claude Code will run on VM, but local tools help
```

## Termux-Specific Configuration

### Storage Access

```bash
# Access internal storage
termux-setup-storage

# Files now available at:
# ~/storage/shared/         # Internal storage
# ~/storage/downloads/       # Downloads folder
# ~/storage/dcim/             # Photos
```

### Background Execution

Termux can run in background:

1. Start a long-running process (like `./vm-start`)
2. Home out of Termux
3. Process continues
4. Return to Termux later

**Note**: Android may kill Termux under memory pressure. Use `tmux` for session persistence.

### Notifications

Termux can show notifications:

```bash
# Install termux-api
pkg install termux-api

# Show notification when VM starts
termux-notification --title "VM Status" --content "VM is starting..."
```

### Boot Scripts (Optional)

Termux:API can run scripts on boot:

```bash
# This requires setup and may not work on all devices
# See: https://wiki.termux.com/wiki/Termux:Boot
```

## SSH Configuration

### SSH Config

```bash
# Create ~/.ssh/config
cat > ~/.ssh/config << 'EOF'
Host portable-cc
    HostName portable-cc-dev.tailnet-name.ts.net
    User ubuntu
    Port 22
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
EOF

# Connect with: ssh portable-cc
```

### SSH Keys

```bash
# Generate key
ssh-keygen -t ed25519

# Copy to VM
ssh-copy-id -i ~/.ssh/id_ed25519.pub ubuntu@portable-cc-dev
```

## mosh Setup

```bash
# Install mosh on Termux
pkg install mosh

# Install mosh-server on VM (if not already installed)
# On VM: sudo apt install mosh-server

# Connect via mosh
mosh ubuntu@portable-cc-dev
```

## tmux in Termux

The same tmux configuration from the main project works:

```bash
# Copy tmux config
cp ~/portable-cc-with-voice/tmux/.tmux.conf ~/.tmux.conf

# Or use zsh integration
cp ~/portable-cc-with-voice/tmux/zshrc-integration.sh ~/.bashrc.termux
source ~/.bashrc.termux
```

## Running vm-lifecycle Scripts

### From Termux (No Laptop Needed!)

```bash
cd ~/portable-cc-with-voice/vm-lifecycle

# Check VM status
./vm-status

# Start VM
./vm-start

# Stop VM
./vm-stop
```

**This is the killer feature**: Control your VM entirely from your phone!

## Keyboard Shortcuts (External Keyboard)

With an external keyboard on Android:

| Key | Action |
|-----|--------|
| `Ctrl` | Termux may need Extra Keys plugin |
| `Tab` | Autocomplete |
| `Ctrl+C` | Cancel |
| `Ctrl+D` | Exit |
| `Ctrl+L` | Clear screen |

## Touch Keyboard Tips

1. **Enable extra keys**:
   - Termux Settings → Additional keys
   - Add keys: TAB, CTRL, ALT, ESC, arrow keys

2. **Use Hacker's Keyboard**:
   - Install from Play Store
   - Has Ctrl, Alt, Tab, Esc, arrows

3. **External keyboard**:
   - USB-C or Bluetooth keyboard recommended
   - Much more productive

## Troubleshooting

### "Package not found"

```bash
# Update package lists
pkg update

# Upgrade packages
pkg upgrade
```

### "Permission denied" for scripts

```bash
# Make scripts executable
chmod +x ~/portable-cc-with-voice/vm-lifecycle/*
```

### "gcloud: command not found"

```bash
# Install Google Cloud SDK
pkg install python
pip install google-cloud-sdk

# Or use REST API via curl
```

### Storage not accessible

```bash
# Re-run storage setup
termux-setup-storage
```

### Termux killed by Android

This happens under memory pressure. Use tmux:
1. Start everything in tmux
2. Detach before leaving Termux
3. Reattach when returning

```bash
# Start tmux
tmux

# Run long-running commands
./vm-start

# Detach: Ctrl+B, D
# Later: tmux attach
```

## Advanced: Termux Widgets

Add Termux widgets to home screen:

1. Long press home screen
2. Add Widget
3. Termux:Widget
4. Configure command (e.g., `./vm-status`)
5. Tap to run

## Advanced: Tasker Integration

Tasker can run Termux scripts:

```bash
# Termux:API creates a Tasker plugin
pkg install termux-api

# In Tasker, use "Termux" action to run:
# /data/data/com.termux/files/home/vm-lifecycle/vm-start
```

See [tasker-profiles.md](tasker-profiles.md) for details.

## Next Steps

1. Complete Termux setup
2. Install recommended packages: [termux-packages.md](termux-packages.md)
3. Set up Tasker automation: [tasker-profiles.md](tasker-profiles.md)
4. Learn workflows: [workflows-guide.md](workflows-guide.md)

## Resources

- Termux Wiki: https://wiki.termux.com/
- Termux GitHub: https://github.com/termux/
- Termux Styling: https://github.com/termux/styling
