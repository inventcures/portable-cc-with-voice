# File Management on Android

This guide covers file transfer, editing, and management options for Android when using Portable Claude Code.

## Overview

Android offers several advantages over iOS for file management:
- Direct file system access
- Multiple file transfer options
- Termux:API for storage access
- Built-in file managers

## File Access Comparison

| Task | iOS | Android |
|------|-----|---------|
| Access device storage | Limited (Termius SFTP) | Full (Termux) |
| Edit local files | Via Termius SFTP | Direct in Termux |
| Transfer files | Termius SFTP, iCloud | Multiple options |
| Sync files | iCloud only | Syncthing, Termux |
| File managers | iOS Files app | Material Files, Termux |

## Option 1: Termux Storage Access

### Setup Termux Storage

```bash
# In Termux
termux-setup-storage
```

This grants access to:
- `~/storage/shared` - Internal storage
- `~/storage/downloads` - Downloads folder
- `~/storage/dcim` - Camera photos
- `~/storage/documents` - Documents
- `~/storage/music` - Music
- `~/storage/pictures` - Pictures
- `~/storage/videos` - Videos

### Accessing Files

```bash
# Navigate to shared storage
cd ~/storage/shared

# List files
ls -la

# Edit files
vim file.txt

# Copy to VM
scp file.txt ubuntu@portable-cc-dev:~/code/
```

## Option 2: Termux:API Advanced Access

### Install Termux:API

```bash
# In Termux
pkg install termux-api

# Also install Termux:API app from Play Store
```

### Termux:API Commands

```bash
# List files in directory
termux-storage-ls ~/storage/shared

# Get file info
termux-stat ~/storage/shared/file.txt

# Share file
termux-share ~/storage/shared/file.txt

# Copy to clipboard
termux-clipboard-set < file.txt
```

## Option 3: Direct File Editing in Termux

### Editing Files Locally

```bash
# In Termux
cd ~/storage/shared/myproject

# Edit with vim
vim main.py

# Edit with nano
nano main.py

# Edit with neovim (if installed)
nvim main.py
```

### Git Operations on Local Files

```bash
# Clone repo to phone storage
cd ~/storage/shared
git clone https://github.com/you/project.git

# Make changes
cd project
vim main.py

# Commit and push
git add .
git commit -m "Fix bug"
git push
```

## Option 4: File Transfer to/from VM

### Via SCP

```bash
# From Android to VM
scp ~/storage/shared/file.txt ubuntu@portable-cc-dev:~/code/

# From VM to Android
scp ubuntu@portable-cc-dev:~/code/output.txt ~/storage/shared/

# Copy directory
scp -r ~/storage/shared/project ubuntu@portable-cc-dev:~/code/
```

### Via Rsync (Better for Large Transfers)

```bash
# Install rsync
pkg install rsync

# Sync directory to VM
rsync -avz ~/storage/shared/project/ ubuntu@portable-cc-dev:~/code/project/

# Sync from VM
rsync -avz ubuntu@portable-cc-dev:~/code/project/ ~/storage/shared/project/
```

### Via mosh with tmux

```bash
# Connect to VM
mosh ubuntu@portable-cc-dev tmux attach

# In tmux, download file from URL
wget https://example.com/file.zip

# Or upload from phone (requires SCP)
# On Android:
scp ~/storage/shared/file.txt ubuntu@portable-cc-dev:~/
```

## Option 5: Syncthing Continuous Sync

### What is Syncthing?

Syncthing provides continuous, bidirectional file synchronization between devices.

### Setup

1. **Install Syncthing**:
   - Play Store: https://play.google.com/store/apps/details=com.nutomic.syncthingandroid
   - F-Droid: https://f-droid.org/packages/com.nutomic.syncthingandroid/

2. **Install on VM**:
   ```bash
   # On VM
   curl -sS https://api.github.com/repos/syncthing/syncthing/releases/latest \
     | grep browser_download_url \
     | grep linux-amd64 \
     | cut -d '"' -f 4 \
     | wget -qi -

   tar -xzf syncthing-*.tar.gz
   sudo mv syncthing-*/syncthing /usr/local/bin/
   syncthing
   ```

3. **Configure**:
   - Open Syncthing web UI (usually http://localhost:8384)
   - Add device (Android phone)
   - Share folder
   - Set folder path

### Benefits

- **Automatic sync**: Changes appear everywhere
- **Version control**: Keeps old versions
- **Works offline**: Syncs when connected
- **No cloud**: Direct device-to-device

## Option 6: JuiceSSH SFTP

### Using JuiceSSH SFTP

1. Open JuiceSSH
2. Long press connection
3. Tap "SFTP"
4. Navigate files
5. Upload/download

**Features**:
- Graphical file browser
- Drag-and-drop
- File permissions
- Edit files remotely

## Option 7: Material Files App

### Install Material Files

```bash
# Play Store
https://play.google.com/store/apps/details=me.zhanghai.android.files
```

### Features

- Clean file browser
- Root access (if rooted)
- SMB/WebDAV support
- File compression

### Use with Termux

1. Open Material Files
2. Navigate to `Android/data/com.termux/files/home`
3. Edit files
4. Return to Termux to run

## Option 8: Git-Based Workflow

### Clone Repos to Phone

```bash
# In Termux
cd ~/storage/shared
git clone https://github.com/your-org/your-project.git

# Or use SSH
git clone git@github.com:your-org/your-project.git
```

### Work Locally, Push to Remote

```bash
cd your-project

# Make changes
vim main.py

# Stage and commit
git add .
git commit -m "Fix authentication bug"

# Push
git push
```

### Pull on VM

```bash
# On VM
cd ~/code/your-project
git pull
```

## Workflow Examples

### Quick Edit Workflow

```bash
# On Android phone
cd ~/storage/shared/myproject
vim config.yaml

# Test locally
python test.py

# If works, push
git add .
git commit -m "Update config"
git push

# On VM, pull changes
# (via mosh/SSH)
cd ~/code/myproject
git pull
```

### Download from VM Workflow

```bash
# From Android, download file from VM
scp ubuntu@portable-cc-dev:~/code/output.csv ~/storage/shared/downloads/

# Open in Android app (Sheets, etc.)
# View/edit
```

### Bulk Transfer Workflow

```bash
# Use rsync for efficiency
rsync -avz --progress \
  ubuntu@portable-cc-dev:~/code/large-project/ \
  ~/storage/shared/large-project/

# Shows progress bar
```

## File Type Handling

### Code Files

Edit in Termux with vim/nano:

```bash
vim main.py
vim index.html
vim style.css
```

### Configuration Files

```bash
# YAML
vim config.yaml

# JSON
vim settings.json

# ENV
vim .env
```

### Images/Media

```bash
# View with Android apps
termux-open ~/storage/shared/image.png

# Or transfer to VM
scp image.png ubuntu@portable-cc-dev:~/static/images/
```

### Documents

```bash
# Edit text files locally
vim document.txt

# For Office docs, use Android apps
termux-open ~/storage/shared/document.docx
```

## Advanced: Termux as File Server

### Start HTTP Server

```bash
# In Termux
cd ~/storage/shared
python -m http.server 8000
```

Then access from any device on Tailscale:
```
http://your-android-tailscale-ip:8000
```

### Start FTP Server

```bash
# Install ftpd
pkg install pure-ftpd

# Configure
pure-ftpd &
```

## Troubleshooting

### Permission Denied

**Problem**: Can't access storage

**Solution**:
```bash
termux-setup-storage
# Grant permissions when prompted
```

### File Not Found

**Problem**: `~/storage/shared` doesn't exist

**Solution**:
- Run `termux-setup-storage`
- Check Android permissions for Termux

### SCP Slow

**Problem**: File transfer very slow

**Solution**:
- Use rsync instead
- Use compression: `scp -C`
- Check Tailscale connection quality

### Edit Corrupts Files

**Problem**: File corrupted after editing

**Solution**:
- Use proper editor (vim, nano)
- Check line endings: `dos2unix file.txt`
- Backup before editing

## Best Practices

### 1. Use Git for Version Control

```bash
# Always commit before editing
git add .
git commit -m "Before editing on Android"
```

### 2. Use Syncthing for Active Projects

Continuous sync = less manual transferring

### 3. Keep Important Files in Tailscale-Synced Locations

```bash
# Use VM as primary storage
# Pull to Android when needed
scp ubuntu@portable-cc-dev:~/important/* ~/storage/shared/
```

### 4. Set Up Aliases

```bash
# In ~/.bashrc (Termux)
alias cc-sync='rsync -avz ~/storage/shared/project/ ubuntu@portable-cc-dev:~/code/project/'
alias cc-pull='rsync -avz ubuntu@portable-cc-dev:~/code/project/ ~/storage/shared/project/'
```

### 5. Use Proper File Locations

```bash
# Code projects
~/storage/shared/Code/

# Documents
~/storage/shared/Documents/

# Downloads
~/storage/downloads/
```

## Quick Reference

### Common Commands

```bash
# Setup storage
termux-setup-storage

# Copy file to VM
scp file.txt ubuntu@portable-cc-dev:~/

# Copy directory
scp -r dir/ ubuntu@portable-cc-dev:~/

# Sync with rsync
rsync -avz local/ ubuntu@portable-cc-dev:remote/

# Pull from VM
rsync -avz ubuntu@portable-cc-dev:remote/ local/
```

### File Locations

```bash
# Shared storage
~/storage/shared/

# Downloads
~/storage/downloads/

# Termux home
~/
```

## Comparison: iOS vs Android File Management

| Task | iOS | Android |
|------|-----|---------|
| View device files | iOS Files app | Material Files, Termux |
| Edit local files | Via Termius SFTP | Direct in Termux |
| Transfer to VM | Termius SFTP | SCP, rsync, Syncthing |
| Continuous sync | iCloud only | Syncthing |
| Script file ops | Limited | Full bash scripting |

**Winner**: Android - much more flexible!

## Next Steps

1. Set up Termux storage access
2. Practice file transfers
3. Configure Syncthing if needed
4. Set up rsync for large transfers
5. Learn workflows: [workflows-guide.md](workflows-guide.md)
