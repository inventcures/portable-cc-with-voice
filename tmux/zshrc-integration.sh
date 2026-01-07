# Tmux Integration for Zsh
#
# This content should be added to your ~/.zshrc
# to enable automatic tmux session attachment on SSH login.
#
# Usage: Add this to ~/.zshrc:
#   source ~/portable-cc-with-voice/tmux/zshrc-integration.sh
#
# Or copy this content directly into ~/.zshrc

# ============================================
# Auto-attach to tmux on SSH login
# ============================================

# Only auto-attach if:
# 1. We're in an SSH session
# 2. tmux is installed
# 3. We're not already in tmux
# 4. We're in an interactive shell

if [[ -n "$SSH_CONNECTION" && -z "$TMUX" && -z "$INSIDE_EMACS" && $- == *i* ]]; then
    # Check if tmux is available
    if command -v tmux &> /dev/null; then

        # Get existing sessions
        EXISTING_SESSIONS=$(tmux list-sessions 2>/dev/null || true)

        if [[ -n "$EXISTING_SESSIONS" ]]; then
            # Sessions exist - offer to attach
            if [[ -n "$WT_SESSION" ]]; then
                # We're in a warp terminal, let it handle things
                :
            else
                # Check if there's only the 'main' session
                SESSION_COUNT=$(echo "$EXISTING_SESSIONS" | wc -l)

                if [[ $SESSION_COUNT -eq 1 ]] && echo "$EXISTING_SESSIONS" | grep -q "^main:"; then
                    # Only main session exists, attach to it
                    exec tmux attach -t main
                else
                    # Multiple sessions or main doesn't exist
                    echo "Existing tmux sessions:"
                    echo "$EXISTING_SESSIONS"
                    echo ""
                    read -p "Attach to session (or press Enter for 'main', 'n' for new): " SESSION

                    case "$SESSION" in
                        n|N|new)
                            exec tmux new -s main
                            ;;
                        "")
                            if tmux has-session -t main 2>/dev/null; then
                                exec tmux attach -t main
                            else
                                exec tmux new -s main
                            fi
                            ;;
                        *)
                            if tmux has-session -t "$SESSION" 2>/dev/null; then
                                exec tmux attach -t "$SESSION"
                            else
                                echo "Session '$SESSION' not found. Creating..."
                                exec tmux new -s "$SESSION"
                            fi
                            ;;
                    esac
                fi
            fi
        else
            # No sessions exist, create 'main'
            exec tmux new -s main
        fi
    fi
fi

# ============================================
# Shell Integration Functions
# ============================================

# Change tmux window name based on current directory
# Uncomment if you want automatic window naming
# function chpwd() {
#     if [[ -n "$TMUX" ]]; then
#         tmux rename-window "$(basename $PWD)"
#     fi
# }

# ============================================
# Aliases for tmux commands
# ============================================

# Quick tmux commands
alias tls='tmux list-sessions'
alias tlw='tmux list-windows -t'
alias tlp='tmux list-panes -t'

# Quick attach
alias tma='tmux attach'
alias tmain='tmux attach -t main'

# New session
alias tmn='tmux new -s'

# Kill session
alias tmk='tmux kill-session -t'

# ============================================
# Helper: Project-based sessions
# ============================================

# Create or attach to a project-specific session
# Usage: tproject myproject
function tproject() {
    local project_name="${1:-$(basename $(pwd))}"
    local session_name="project-$project_name"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        tmux attach -t "$session_name"
    else
        tmux new -s "$session_name" -c "$PWD"
    fi
}

# ============================================
# Helper: Claude Code session
# ============================================

# Quick attach to Claude Code session
# Usage: tc
function tc() {
    if tmux has-session -t claude 2>/dev/null; then
        tmux attach -t claude
    else
        tmux new -s claude -n "claude-code"
    fi
}
