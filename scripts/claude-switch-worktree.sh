#!/bin/bash
# claude-switch-worktree.sh - Switch between Claude Code worktrees

set -e

# Default values
WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: claude-switch-worktree.sh NAME [OPTIONS]"
      echo "Switch to a different Claude Code worktree"
      echo ""
      echo "Options:"
      echo "  -d, --dir PATH        Custom worktrees directory (default: $WORKTREES_DIR)"
      echo "  -l, --list            List available worktrees and exit"
      echo "  -h, --help            Show this help message"
      echo ""
      echo "Example:"
      echo "  claude-switch-worktree.sh update-readme"
      echo ""
      echo "Note: This script generates instructions for switching worktrees."
      echo "      You must manually execute the 'cd' command shown."
      exit 0
      ;;
    -d|--dir)
      WORKTREES_DIR="$2"
      shift 2
      ;;
    -l|--list)
      echo "Available worktrees:"
      # Use claude-list-worktrees.sh with simple format
      if command -v claude-list-worktrees.sh >/dev/null 2>&1; then
        claude-list-worktrees.sh --format simple | sed 's/^isolated-pymcp-/  /'
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
  echo "Run 'claude-switch-worktree.sh --help' for usage information"
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

# Get issue info if available
ISSUE_INFO=""
if [[ -f "$WORKTREE_PATH/.claude/issue.md" ]]; then
  ISSUE_INFO=$(grep -o "#[0-9]*" "$WORKTREE_PATH/.claude/issue.md" 2>/dev/null || echo "")
  if [[ -n "$ISSUE_INFO" ]]; then
    ISSUE_INFO=" (Issue $ISSUE_INFO)"
  fi
fi

# Print instructions
echo "To switch to worktree ${FULL_WORKTREE_NAME}${ISSUE_INFO}:"
echo ""
echo "  cd ${WORKTREE_PATH}"
echo "  claude"
echo ""
echo "Current branch: ${BRANCH}"
echo ""
echo "NOTE: You must manually execute the 'cd' command shown above."
echo "      A new Claude Code session can be started with 'claude' after switching."