#!/bin/bash
# claude-list-worktrees.sh - List git worktrees for Claude Code

set -e

# Default values
WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"
FORMAT="table"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: claude-list-worktrees.sh [OPTIONS]"
      echo "List git worktrees associated with Claude Code"
      echo ""
      echo "Options:"
      echo "  -d, --dir PATH        Custom worktrees directory (default: $WORKTREES_DIR)"
      echo "  -f, --format FORMAT   Output format: table, json, simple (default: table)"
      echo "  -h, --help            Show this help message"
      echo ""
      echo "Example:"
      echo "  claude-list-worktrees.sh --format json"
      exit 0
      ;;
    -d|--dir)
      WORKTREES_DIR="$2"
      shift 2
      ;;
    -f|--format)
      FORMAT="$2"
      shift 2
      ;;
    *)
      echo "Error: Unknown argument '$1'"
      exit 1
      ;;
  esac
done

# Ensure worktrees directory exists
if [[ ! -d "$WORKTREES_DIR" ]]; then
  echo "Worktrees directory not found: $WORKTREES_DIR"
  echo "No worktrees have been created yet."
  exit 0
fi

# Get git worktree list
REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_LIST=$(git worktree list)

# Filter only those in our worktrees directory
mapfile -t CLAUDE_WORKTREES < <(find "$WORKTREES_DIR" -maxdepth 1 -name "isolated-pymcp-*" -type d | sort)

if [[ ${#CLAUDE_WORKTREES[@]} -eq 0 ]]; then
  echo "No Claude worktrees found in $WORKTREES_DIR"
  exit 0
fi

# Output in requested format
case "$FORMAT" in
  "json")
    echo "{"
    echo "  \"worktrees\": ["
    
    for ((i=0; i<${#CLAUDE_WORKTREES[@]}; i++)); do
      WORKTREE="${CLAUDE_WORKTREES[$i]}"
      WORKTREE_NAME=$(basename "$WORKTREE")
      
      # Get branch info
      BRANCH=$(cd "$WORKTREE" && git rev-parse --abbrev-ref HEAD)
      
      # Get issue number if available
      ISSUE=""
      if [[ -f "$WORKTREE/.claude/issue.md" ]]; then
        ISSUE=$(grep -oP "#\K\d+" "$WORKTREE/.claude/issue.md" || echo "")
      fi
      
      # Last modified
      LAST_MODIFIED=$(cd "$WORKTREE" && git log -1 --format="%ad" --date=relative 2>/dev/null || echo "Never")
      
      echo "    {"
      echo "      \"name\": \"$WORKTREE_NAME\","
      echo "      \"path\": \"$WORKTREE\","
      echo "      \"branch\": \"$BRANCH\","
      echo "      \"issue\": \"$ISSUE\","
      echo "      \"last_modified\": \"$LAST_MODIFIED\""
      
      if [[ $i -eq $((${#CLAUDE_WORKTREES[@]} - 1)) ]]; then
        echo "    }"
      else
        echo "    },"
      fi
    done
    
    echo "  ]"
    echo "}"
    ;;
    
  "simple")
    for WORKTREE in "${CLAUDE_WORKTREES[@]}"; do
      echo "$(basename "$WORKTREE")"
    done
    ;;
    
  *)  # table format by default
    printf "%-30s %-25s %-15s %-20s\n" "WORKTREE" "BRANCH" "ISSUE" "LAST MODIFIED"
    printf "%-30s %-25s %-15s %-20s\n" "$(printf '%0.s-' {1..30})" "$(printf '%0.s-' {1..25})" "$(printf '%0.s-' {1..15})" "$(printf '%0.s-' {1..20})"
    
    for WORKTREE in "${CLAUDE_WORKTREES[@]}"; do
      WORKTREE_NAME=$(basename "$WORKTREE")
      
      # Get branch info
      BRANCH=$(cd "$WORKTREE" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "N/A")
      
      # Get issue number if available
      ISSUE=""
      if [[ -f "$WORKTREE/.claude/issue.md" ]]; then
        ISSUE=$(grep -oP "#\K\d+" "$WORKTREE/.claude/issue.md" || echo "")
      fi
      
      # Last modified
      LAST_MODIFIED=$(cd "$WORKTREE" && git log -1 --format="%ad" --date=relative 2>/dev/null || echo "Never")
      
      printf "%-30s %-25s %-15s %-20s\n" "$WORKTREE_NAME" "$BRANCH" "${ISSUE:--}" "$LAST_MODIFIED"
    done
    ;;
esac