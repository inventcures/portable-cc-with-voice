# Recommended Termux Packages for Portable Claude Code

This guide lists recommended packages to install in Termux for optimal Portable Claude Code experience.

## Essential Packages

Install these first:

```bash
pkg update && pkg upgrade
pkg install git curl jq vim tmux mosh openssh nano
```

| Package | Purpose |
|---------|---------|
| `git` | Version control, clone repo |
| `curl` | HTTP requests, API calls |
| `jq` | JSON parsing for API responses |
| `vim` | Text editor (or use neovim) |
| `tmux` | Session persistence |
| `mosh` | Resilient SSH |
| `openssh` | SSH client |
| `nano` | Simple text editor |

## Development Tools

```bash
# Python
pkg install python

# Node.js
pkg install nodejs npm

# Build tools
pkg install clang make cmake
```

## Enhanced Tools

```bash
# Better alternatives
pkg install neovim        # Enhanced vim
pkg install htop           # Process viewer
pkg install btop           # Modern htop
pkg install ripgrep        # Fast grep (rg)
pkg install fzf            # Fuzzy finder
pkg install bat            # Better cat
pkg install exa            # Better ls (or use eza)
```

## Termux-Specific

```bash
# Storage access
termux-setup-storage

# Termux API (for Tasker integration, notifications)
pkg install termux-api termux-exec

# Sound (for audio feedback)
pkg install termux-audio
```

## Claude Code Related

These aren't for running Claude Code (that's on the VM), but for local operations:

```bash
# For running the notify hook locally
pkg install curl jq

# For git worktrees
pkg install git

# For tmux sessions (attach from phone)
pkg install tmux mosh
```

## Package Comparison

| Category | iOS | Android Termux |
|----------|-----|-----------------|
| Terminal | Termius | Termux |
| tmux | Via SSH | Native! |
| git | Via SSH | Native! |
| jq | Via SSH | Native! |
| vim | Via SSH | Native! |
| mosh | Termius | Native! |

**Key Advantage**: Termux can run many tools locally without needing an SSH connection.

## Installation Commands

### Quick Start

```bash
# Essential only
pkg install git curl jq tmux mosh openssh
```

### Full Development

```bash
# Everything for development
pkg install git curl jq vim tmux mosh openssh nano \
            python nodejs npm clang make cmake \
            neovim htop btop ripgrep fzf bat exa \
            termux-api termux-exec
```

### Minimal

```bash
# Just the basics for vm-lifecycle scripts
pkg install git curl jq openssh
```

## Package Sources

### Official Repositories

Termux uses its own repositories:

```bash
# View sources
cat $PREFIX/etc/apt/sources.list

# Usually:
# https://packages.termux.dev/apt/termux-main/
# https://packages.termux.dev/apt/termux-root/
# https://packages.termux.dev/apt/termux-x11/
```

### Third-Party Repositories

Some packages need third-party repos:

```bash
# Example: Root packages (not recommended, can break things)
# pkg install root-repo

# Only use if you know what you're doing!
```

## Storage Setup

```bash
# Access Android storage
termux-setup-storage

# Available locations:
# ~/storage/shared/         # Internal storage
# ~/storage/downloads/       # Downloads
# ~/storage/dcim/             # Camera
# ~/storage/music/            # Music
# ~/storage/pictures/         # Pictures
# ~/storage/documents/        # Documents
```

## Configurations

### Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global core.editor "vim"
git config --global init.defaultBranch "main"
```

### Vim Configuration

```bash
# Basic vimrc
cat > ~/.vimrc << 'EOF'
set nocompatible
filetype off
set number
set relativenumber
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set incsearch
syntax on
filetype plugin indent on
EOF
```

### Tmux Configuration

```bash
# Use the project's tmux config
cp ~/portable-cc-with-voice/tmux/.tmux.conf ~/.tmux.conf
```

### Shell Configuration

```bash
# Add to ~/.bashrc
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# VM aliases
alias cc-start='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-start'
alias cc-stop='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-stop'
alias cc-status='cd ~/portable-cc-with-voice/vm-lifecycle && ./vm-status'
```

## Usage Examples

### Check VM Status from Phone

```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-status
```

### Start VM from Phone

```bash
# In Termux
cd ~/portable-cc-with-voice/vm-lifecycle
./vm-start
```

### Quick Git Check

```bash
# In Termux, in any git repo
git status
git log --oneline -5
```

### Edit Config Files

```bash
# Edit project config
vim ~/portable-cc-with-voice/vm-lifecycle/vm-start
```

## Storage Space Management

```bash
# Check space
df -h

# Clean package cache
pkg clean

# Remove unused packages
pkg autoremove
```

## Updating Packages

```bash
# Update all packages
pkg update && pkg upgrade

# Update specific package
pkg upgrade <package-name>
```

## Troubleshooting

### "Package not found"

```bash
# Update package list
pkg update

# Search for package
pkg search <name>
```

### "Cannot install package"

Some packages aren't available in Termux. Alternatives:
- `htop` → Works
- `btop` → May need compilation
- `exa` → Use `eza` or `ls`

### Architecture Issues

```bash
# Check your architecture
uname -m

# Most phones are aarch64
# Some packages only work on specific architectures
```

## Next Steps

1. Install essential packages
2. Configure environment
3. Clone the repository
4. Set up Tasker: [tasker-profiles.md](tasker-profiles.md)
5. Learn workflows: [workflows-guide.md](workflows-guide.md)
