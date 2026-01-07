#!/bin/bash
# List All Git Worktrees and Their Ports
#
# Shows all worktrees in the Code directory with their
# allocated ports and current status.
#
# Usage: ./list-worktrees.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
BASE_DIR="${BASE_DIR:-$HOME/Code}"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${CYAN}"
echo "=================================="
echo "Git Worktrees"
echo "=================================="
echo -e "${NC}"
echo "Base directory: $BASE_DIR"
echo ""

# Find all directories that look like worktrees
# (have .git file pointing to main repo)
WORKTREE_COUNT=0

for dir in "$BASE_DIR"/*; do
    if [[ -d "$dir" ]]; then
        # Check if this is a worktree (has .git file, not directory)
        if [[ -f "$dir/.git" ]]; then
            WORKTREE_COUNT=$((WORKTREE_COUNT + 1))
            WORKTREE_NAME=$(basename "$dir")

            # Get git info
            if pushd "$dir" &> /dev/null; then
                BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
                COMMIT=$(git log -1 --oneline 2>/dev/null || echo "no commits")
                STATUS=$(git status --porcelain 2>/dev/null | wc -l)
                popd &> /dev/null

                # Get ports if available
                WEB_PORT=""
                API_PORT=""
                if [[ -f "$dir/.env.ports" ]]; then
                    source "$dir/.env.ports"
                fi

                # Display
                echo -e "${GREEN}▸ $WORKTREE_NAME${NC}"
                echo "  Path:     $dir"
                echo "  Branch:   $BRANCH"
                echo "  Commit:   $COMMIT"

                if [[ -n "$WEB_PORT" ]]; then
                    echo "  Ports:    WEB=${WEB_PORT}, API=${API_PORT}"
                else
                    echo "  Ports:    (not configured)"
                fi

                if [[ $STATUS -gt 0 ]]; then
                    echo -e "  Status:   ${YELLOW}Uncommitted changes${NC}"
                else
                    echo -e "  Status:   ${GREEN}Clean${NC}"
                fi

                echo ""
            fi
        fi
    fi
done

# Also check main repos (have .git directory)
for dir in "$BASE_DIR"/*; do
    if [[ -d "$dir/.git" && ! -L "$dir/.git" ]]; then
        WORKTREE_NAME=$(basename "$dir")

        # Skip if already listed as worktree
        continue

        WORKTREE_COUNT=$((WORKTREE_COUNT + 1))

        if pushd "$dir" &> /dev/null; then
            BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
            COMMIT=$(git log -1 --oneline 2>/dev/null || echo "no commits")
            popd &> /dev/null

            # Get ports if available
            WEB_PORT=""
            API_PORT=""
            if [[ -f "$dir/.env.ports" ]]; then
                source "$dir/.env.ports"
            fi

            echo -e "${CYAN}▸ $WORKTREE_NAME (main)${NC}"
            echo "  Path:     $dir"
            echo "  Branch:   $BRANCH"
            echo "  Commit:   $COMMIT"

            if [[ -n "$WEB_PORT" ]]; then
                echo "  Ports:    WEB=${WEB_PORT}, API=${API_PORT}"
            else
                echo "  Ports:    (not configured)"
            fi

            echo ""
        fi
    fi
done

if [[ $WORKTREE_COUNT -eq 0 ]]; then
    log_warning "No worktrees found in $BASE_DIR"
    echo ""
    echo "Create a worktree:"
    echo "  ./create-worktree.sh <feature-name> <project-name>"
else
    echo "Total: $WORKTREE_COUNT workspace(s)"
    echo ""
fi

# Show current tmux sessions if available
if command -v tmux &> /dev/null && tmux list-sessions &> /dev/null; then
    echo -e "${CYAN}Active tmux sessions:${NC}"
    tmux list-sessions 2>/dev/null | sed 's/^/  /'
    echo ""
fi
