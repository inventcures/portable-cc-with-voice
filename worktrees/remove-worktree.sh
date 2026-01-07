#!/bin/bash
# Remove Git Worktree
#
# Safely removes a git worktree and optionally prunes
# the worktree list.
#
# Usage: ./remove-worktree.sh <worktree-name> [project-name]
#
# Example:
#   ./remove-worktree.sh auth myproject
#   Removes: ~/Code/myproject-auth

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Parse arguments
WORKTREE_NAME="${1:-}"
PROJECT_NAME="${2:-}"

if [[ -z "$WORKTREE_NAME" ]]; then
    log_error "Worktree name required."
    echo ""
    echo "Usage: $0 <worktree-name> [project-name]"
    echo ""
    echo "Examples:"
    echo "  $0 auth myproject"
    echo "  $0 myproject-auth"
    echo ""
    exit 1
fi

# Construct path
if [[ -n "$PROJECT_NAME" ]]; then
    WORKTREE_PATH="$BASE_DIR/${PROJECT_NAME}-${WORKTREE_NAME}"
else
    # Worktree name might already include project prefix
    WORKTREE_PATH="$BASE_DIR/$WORKTREE_NAME"
fi

# Check if path exists
if [[ ! -d "$WORKTREE_PATH" ]]; then
    log_error "Worktree not found: $WORKTREE_PATH"
    echo ""
    echo "List available worktrees:"
    echo "  ./list-worktrees.sh"
    exit 1
fi

# Check if it's a worktree
if [[ ! -f "$WORKTREE_PATH/.git" ]]; then
    log_error "Not a worktree (no .git file): $WORKTREE_PATH"
    log_warning "This appears to be a regular git repository."
    log_info "Only remove worktrees, not main repositories!"
    exit 1
fi

# Find the main repo to prune from
MAIN_REPO=""
if [[ -f "$WORKTREE_PATH/.git" ]]; then
    # Read the .git file to find main repo
    GIT_FILE_CONTENT=$(cat "$WORKTREE_PATH/.git")
    if [[ "$GIT_FILE_CONTENT" =~ gitdir:\ (.+) ]]; then
        GITDIR="${BASH_REMATCH[1]}"
        # Resolve relative path
        if [[ "$GITDIR" =~ ^\.\. ]]; then
            MAIN_REPO="$(cd "$WORKTREE_PATH" && cd "$GITDIR" && pwd)"
            MAIN_REPO="$(dirname "$MAIN_REPO")"
        else
            log_error "Cannot determine main repository path."
            exit 1
        fi
    fi
fi

# Show what will be removed
echo ""
echo -e "${YELLOW}=================================="
echo "Remove Worktree"
echo "==================================${NC}"
echo ""
echo "Path: $WORKTREE_PATH"
if [[ -n "$MAIN_REPO" ]]; then
    echo "Main repo: $MAIN_REPO"
fi
echo ""

# Check for uncommitted changes
if pushd "$WORKTREE_PATH" &> /dev/null; then
    UNCOMMITTED=$(git status --porcelain 2>/dev/null | wc -l)
    popd &> /dev/null

    if [[ $UNCOMMITTED -gt 0 ]]; then
        log_error "Worktree has uncommitted changes!"
        echo ""
        echo "Commit or stash changes first:"
        echo "  cd $WORKTREE_PATH"
        echo "  git status"
        echo "  git add ."
        echo "  git commit -m 'WIP'"
        echo ""
        exit 1
    fi
fi

# Confirm
read -p "Remove this worktree? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled."
    exit 0
fi

# Remove the worktree
log_info "Removing worktree..."

if [[ -n "$MAIN_REPO" ]]; then
    # Use git worktree remove if available (git 2.17+)
    if git -C "$MAIN_REPO" worktree remove &> /dev/null; then
        git -C "$MAIN_REPO" worktree remove "$WORKTREE_PATH"
    else
        # Fallback: manual removal
        rm -rf "$WORKTREE_PATH"
        git -C "$MAIN_REPO" worktree prune
    fi
else
    # Just remove the directory
    rm -rf "$WORKTREE_PATH"
fi

log_success "Worktree removed."

# Prune worktree list
if [[ -n "$MAIN_REPO" ]]; then
    log_info "Pruning worktree list..."
    git -C "$MAIN_REPO" worktree prune
    log_success "Pruned."
fi

echo ""
echo -e "${GREEN}Worktree removed successfully.${NC}"
echo ""
echo "Remaining worktrees:"
./list-worktrees.sh 2>/dev/null || echo "  (run ./list-worktrees.sh to see)"
echo ""
