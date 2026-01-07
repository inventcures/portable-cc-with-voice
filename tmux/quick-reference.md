# tmux Quick Reference

Mobile-optimized tmux keybindings for Portable Claude Code.

## Prefix Key

All tmux commands start with the **prefix key**: `Ctrl-a` (written as `C-a`)

**Note**: If you're coming from screen, this is the same prefix you're used to!

## Most Common Commands

| Command | Action |
|---------|--------|
| `C-a c` | Create new window |
| `C-a n` | Next window |
| `C-a p` | Previous window |
| `C-a 0-9` | Go to window by number |
| `C-a d` | Detach from session (keeps it running) |
| `C-a |` | Split window vertically (left/right) |
| `C-a -` | Split window horizontally (top/bottom) |

## Pane Navigation

| Command | Action |
|---------|--------|
| `C-a h` | Move to left pane |
| `C-a j` | Move to bottom pane |
| `C-a k` | Move to top pane |
| `C-a l` | Move to right pane |
| `C-a o` | Cycle through panes |
| `C-a Arrow` | Also works with arrow keys |

## Pane Resizing

| Command | Action |
|---------|--------|
| `C-a H` | Resize pane left |
| `C-a J` | Resize pane down |
| `C-a K` | Resize pane up |
| `C-a L` | Resize pane right |

## Window Management

| Command | Action |
|---------|--------|
| `C-a c` | Create new window |
| `C-a ,` | Rename current window |
| `C-a &` | Close current window |
| `C-a w` | List all windows |
| `C-a f` | Find window by name |

## Copy Mode (Vi Style)

| Command | Action |
|---------|--------|
| `C-a [` | Enter copy mode |
| `v` | Start selection (in copy mode) |
| `y` | Copy selection |
| `q` or `Esc` | Quit copy mode |
| `j`/`k` | Scroll down/up |
| `Ctrl-u`/`Ctrl-d` | Scroll half page up/down |
| `Ctrl-b`/`Ctrl-f` | Scroll full page up/down |

## Session Management

| Command | Action |
|---------|--------|
| `C-a s` | List and switch sessions |
| `C-a $` | Rename session |
| `C-a d` | Detach from session |
| `C-a D` | Choose client to detach |

## Layouts

| Command | Action |
|---------|--------|
| `C-a Space` | Cycle through layouts |
| `C-a E` | Even horizontal |
| `C-a e` | Even vertical |
| `C-a M` | Main horizontal |
| `C-a m` | Main vertical |
| `C-a T` | Tiled |

## Useful Shell Commands

```bash
# List all sessions
tmux list-sessions
# or: tls

# Attach to a specific session
tmux attach -t session-name
# or: tma session-name

# Create a new session
tmux new -s session-name
# or: tmn session-name

# Kill a session
tmux kill-session -t session-name
# or: tmk session-name

# Attach to the 'main' session
tmux attach -t main
# or: tmain
```

## Mobile-Specific Tips

### For iOS Termius:

1. **External Keyboard**: Add `Ctrl` key to your extended keyboard in Termius settings
2. **Custom Keys**: You can add custom key bindings in Termius for common commands
3. **Gestures**: Swipe left/right on the terminal to switch windows (if enabled)

### Without External Keyboard:

1. Use the **key cheatsheet** in Termius (tap the keyboard icon)
2. **Long press** on keys for alternatives (long press '0' for 'Ctrl')
3. Use **tmux prefix + arrow keys** for pane navigation (easier than hjkl)

## Troubleshooting

### Can't scroll in tmux?

Enter copy mode first: `C-a [`, then use arrow keys or scroll gestures.

### Session won't detach?

Force detach: `C-a D`, then choose your session.

### Accidentally hit prefix?

Just press `C-a` again to cancel, or wait 1 second.

## Claude Code Workflow

Typical multi-window setup for Claude Code:

```
Window 1 (main):     Primary worktree
Window 2 (feature):  Feature branch
Window 3 (review):   Code review
Window 4 (build):    Build/test output
```

Switch between windows while Claude works in one, review in another!
