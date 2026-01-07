# Multi-Agent tmux Workflow Guide

Using tmux to run multiple Claude Code agents in parallel on your mobile development VM.

## Overview

With tmux, you can run multiple Claude Code sessions simultaneously, each in its own window. This allows you to:

- Work on multiple features in parallel
- Let Claude work in one window while you review in another
- Keep build/test processes running separately
- Switch contexts without losing state

## Session Layout

### Recommended Window Structure

```
Session: main
├── Window 1: main           # Primary development
├── Window 2: feature-auth   # Feature branch: authentication
├── Window 3: feature-db     # Feature branch: database
├── Window 4: review         # PR/code review
└── Window 5: logs           # Build/test logs
```

## Quick Start

### 1. Start a tmux session

```bash
tmux new -s main
```

### 2. Create windows for each feature

```bash
# In tmux:
C-a c          # Create new window
C-a ,          # Rename to "main"
C-a c          # Create another window
C-a ,          # Rename to "feature-auth"
# Repeat for each feature...
```

### 3. In each window, set up your worktree

```bash
cd ~/Code/myproject-feature-auth
claude-code
```

### 4. Switch between windows

```bash
C-a n          # Next window
C-a p          # Previous window
C-a 1          # Go to window 1
C-a 2          # Go to window 2
# etc.
```

## Git Worktree + tmux Workflow

### Setup

```bash
# Main project
cd ~/Code/myproject
git checkout main

# Create worktrees for features
git worktree add ../myproject-auth feature/auth
git worktree add ../myproject-db feature/db
git worktree add ../myproject-ui feature/ui
```

### In tmux

```bash
# Window 1: main
cd ~/Code/myproject
C-a , main

# Window 2: auth feature
cd ~/Code/myproject-auth
C-a , auth

# Window 3: db feature
cd ~/Code/myproject-db
C-a , db

# Window 4: ui feature
cd ~/Code/myproject-ui
C-a , ui
```

### Port Allocation

When running dev servers, use the port allocation script:

```bash
~/portable-cc-with-voice/worktrees/create-worktree.sh auth myproject
# Output: Ports: WEB=8042, API=9042
```

Then start your server with those ports in that window.

## Parallel Development Example

### Scenario: Refactor while fixing bugs

**Window 1 (main)**: Working on a refactor
```
claude-code: "Refactor the user service to use the new repository pattern"
```

**Window 2 (bugfix)**: Urgent bug comes in
```
# Switch to window 2
C-a 2
claude-code: "Fix the login timeout issue"
```

**Window 3 (review)**: Review PR while waiting
```
# Switch to window 3
C-a 3
gh pr view 123
claude-code: "Review this PR"
```

### Workflow

1. Start Claude on a task in window 1
2. While it's thinking/working, switch to window 2
3. Start another Claude task or do manual work
4. When Claude in window 1 needs input, you get a notification
5. Switch back to window 1: `C-a 1`
6. Respond to Claude
7. Switch back to window 2: `C-a 2`

## Mobile-Specific Considerations

### Window Naming

Rename windows descriptively so you can quickly find what you need:

```bash
C-a ,          # Rename
Type: auth     # Name it
```

### Status Bar

The status bar shows `[session-name]` so you always know where you are.

### Context Switching

On mobile, you can:
1. Background Termius (answer a call, check email)
2. Come back - everything is still running
3. Claude may have a question waiting

### Notification Integration

With the push notification hook:
- Claude asks a question in window 3
- You get a push notification on iOS
- Notification tells you which project
- You switch to the right window

## Advanced: Nested Sessions

For complex setups, you can nest tmux sessions:

```bash
# Outer session: main
#   Window 1: project-main (inner session)
#   Window 2: project-side (inner session)

# Create inner session with different prefix
tmux -L project-main new -s main
# Change prefix to C-b in inner session
```

Then you can:
- `C-a 1` - Switch to project-main window
- `C-b` - Send prefix to inner session

## Quick Reference Commands

```bash
# List all windows
C-a w

# Show window list with preview
C-a W

# Move window
C-a .          # Move to next number
C-a ,          # Rename then type: target-number

# Join pane to window
C-a :          # Command mode
join-pane -t :2   # Join current pane to window 2

# Break pane into window
C-a !
```

## Tips for Productivity

1. **Use descriptive window names** - "auth", "db", not "1", "2"
2. **Keep similar tasks in same session** - All feature branches in one session
3. **Use layouts** - `C-a Space` to cycle layouts for better visibility
4. **Detach often** - `C-a d` when taking a break, reconnect later
5. **Script your setup** - Create a script that sets up your standard layout

## Sample Setup Script

```bash
#!/bin/bash
# setup-dev-session.sh

SESSION="dev"

# Create or attach to session
if tmux has-session -t $SESSION 2>/dev/null; then
    tmux attach -t $SESSION
    exit
fi

# Create session
tmux new -s $SESSION -n main -d

# Create windows
tmux new-window -t $SESSION:2 -n auth
tmux new-window -t $SESSION:3 -n db
tmux new-window -t $SESSION:4 -n review
tmux new-window -t $SESSION:5 -n logs

# Attach to session
tmux select-window -t $SESSION:1
tmux attach -t $SESSION
```

## Troubleshooting

### Can't find which window has Claude?

```bash
C-a w          # List windows
# Look for the one running claude-code
```

### Accidentally closed a window?

Windows are closed when last pane exits. Use:
```bash
C-a _          # Kill pane (careful!)
```

Better to detach: `C-a d`

### Session got stuck?

```bash
# From another terminal
tmux kill-session -t main
# Or from within
C-a :          # Command mode
kill-session
```
