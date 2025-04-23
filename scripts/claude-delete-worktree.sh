#!/usr/bin/env bash
# claude-delete-worktree.sh - Delete a Claude Code worktree

set -e

# Default values
WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"
DELETE_BRANCH=false
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: claude-delete-worktree.sh NAME [OPTIONS]"
      echo "Delete a Claude Code worktree"
      echo ""
      echo "Options:"
      echo "  -b, --delete-branch   Also delete the associated branch"
      echo "  -f, --force           Force deletion even with uncommitted changes"
      echo "  -d, --dir PATH        Custom worktrees directory (default: $WORKTREES_DIR)"
      echo "  -l, --list            List available worktrees and exit"
      echo "  -h, --help            Show this help message"
      echo ""
      echo "Example:"
      echo "  claude-delete-worktree.sh update-readme --delete-branch"
      exit 0
      ;;
    -b|--delete-branch)
      DELETE_BRANCH=true
      shift
      ;;
    -f|--force)
      FORCE=true
      shift
      ;;
    -d|--dir)
      WORKTREES_DIR="$2"
      shift 2
      ;;
    -l|--list)
      echo "Available worktrees:"
      # Use claude-list-worktrees.sh with simple format
      if command -v claude-list-worktrees.sh >/dev/null 2>&1; then
        claude-list-worktrees.sh --format table
      else
        find "$WORKTREES_DIR" -maxdepth 1 -name "isolated-pymcp-*" -type d | sort | sed 's/^.*isolated-pymcp-/  /'
      fi
      exit 0
      ;;
    *)
      if [[ -z "$WORKTREE_NAME" ]]; then
        WORKTREE_NAME="$1"
        shift
      else
        echo "Error: Unknown argument '$1'"
        exit 1
      fi
      ;;
  esac
done

# Validate required arguments
if [[ -z "$WORKTREE_NAME" ]]; then
  echo "Error: Worktree name is required"
  echo "Run 'claude-delete-worktree.sh --help' for usage information"
  exit 1
fi

# Normalize the worktree name
if [[ "$WORKTREE_NAME" != isolated-pymcp-* ]]; then
  FULL_WORKTREE_NAME="isolated-pymcp-${WORKTREE_NAME}"
else
  FULL_WORKTREE_NAME="$WORKTREE_NAME"
fi

# Set up path
WORKTREE_PATH="${WORKTREES_DIR}/${FULL_WORKTREE_NAME}"

# Check if worktree exists
if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "Error: Worktree not found at $WORKTREE_PATH"
  echo ""
  echo "Available worktrees:"
  # Use claude-list-worktrees.sh with simple format
  if command -v claude-list-worktrees.sh >/dev/null 2>&1; then
    claude-list-worktrees.sh --format simple | sed 's/^isolated-pymcp-/  /'
  else
    find "$WORKTREES_DIR" -maxdepth 1 -name "isolated-pymcp-*" -type d | sort | sed 's/^.*isolated-pymcp-/  /'
  fi
  exit 1
fi

# Get branch info
BRANCH=$(cd "$WORKTREE_PATH" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Unknown")

# Check for uncommitted changes
if [[ "$FORCE" != true ]]; then
  UNCOMMITTED=$(cd "$WORKTREE_PATH" && git status --porcelain)
  if [[ -n "$UNCOMMITTED" ]]; then
    echo "Error: Worktree has uncommitted changes. Use --force to delete anyway."
    echo ""
    echo "Uncommitted changes:"
    cd "$WORKTREE_PATH" && git status --short
    exit 1
  fi
fi

# Delete the worktree
echo "Deleting worktree: ${FULL_WORKTREE_NAME} (${WORKTREE_PATH})"
git worktree remove ${FORCE:+--force} "$WORKTREE_PATH"

# Delete the branch if requested
if [[ "$DELETE_BRANCH" == true ]]; then
  echo "Deleting associated branch: ${BRANCH}"
  git branch -D "$BRANCH"
fi

echo ""
echo "Worktree deleted successfully."
if command -v claude-list-worktrees.sh >/dev/null 2>&1; then
  echo ""
  echo "Remaining worktrees:"
  claude-list-worktrees.sh --format table
fi