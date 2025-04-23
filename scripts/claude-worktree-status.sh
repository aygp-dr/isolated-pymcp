#!/bin/bash
# claude-worktree-status.sh - Display status of Claude Code worktrees

set -e

# Default values
WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"
FORMAT="table"
SHOW_CHANGES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: claude-worktree-status.sh [OPTIONS]"
      echo "Display status of Claude Code worktrees"
      echo ""
      echo "Options:"
      echo "  -d, --dir PATH        Custom worktrees directory (default: $WORKTREES_DIR)"
      echo "  -f, --format FORMAT   Output format: table, json (default: table)"
      echo "  -c, --changes         Show details of uncommitted changes"
      echo "  -h, --help            Show this help message"
      echo ""
      echo "Example:"
      echo "  claude-worktree-status.sh --changes"
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
    -c|--changes)
      SHOW_CHANGES=true
      shift
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

# Get Claude worktrees
mapfile -t CLAUDE_WORKTREES < <(find "$WORKTREES_DIR" -maxdepth 1 -name "isolated-pymcp-*" -type d | sort)

if [[ ${#CLAUDE_WORKTREES[@]} -eq 0 ]]; then
  echo "No Claude worktrees found in $WORKTREES_DIR"
  exit 0
fi

# Function to get status of a worktree
get_worktree_status() {
  local worktree="$1"
  local name=$(basename "$worktree")
  local branch=$(cd "$worktree" && git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Unknown")
  
  # Get issue number if available
  local issue=""
  if [[ -f "$worktree/.claude/issue.md" ]]; then
    issue=$(grep -oP "#\K\d+" "$worktree/.claude/issue.md" || echo "")
  fi
  
  # Get status info
  local status_output=$(cd "$worktree" && git status --porcelain)
  local status="Clean"
  local changes=0
  
  if [[ -n "$status_output" ]]; then
    changes=$(echo "$status_output" | wc -l)
    status="Changes (${changes})"
  fi
  
  # Get last commit info
  local last_commit=$(cd "$worktree" && git log -1 --format="%h: %s" --date=relative 2>/dev/null || echo "No commits")
  local last_commit_time=$(cd "$worktree" && git log -1 --format="%ar" --date=relative 2>/dev/null || echo "Never")
  
  # Return as associative array
  echo "$name|$branch|$issue|$status|$changes|$last_commit|$last_commit_time"
}

# Create temporary directory for status files
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Get status for all worktrees in parallel
for i in "${!CLAUDE_WORKTREES[@]}"; do
  worktree="${CLAUDE_WORKTREES[$i]}"
  get_worktree_status "$worktree" > "$TMP_DIR/$i.status" &
done

# Wait for all background jobs to finish
wait

# Collect results
declare -a RESULTS
for i in "${!CLAUDE_WORKTREES[@]}"; do
  RESULTS[$i]=$(cat "$TMP_DIR/$i.status")
done

# Output in requested format
case "$FORMAT" in
  "json")
    echo "{"
    echo "  \"worktrees\": ["
    
    for ((i=0; i<${#RESULTS[@]}; i++)); do
      IFS='|' read -r name branch issue status changes last_commit last_commit_time <<< "${RESULTS[$i]}"
      
      echo "    {"
      echo "      \"name\": \"$name\","
      echo "      \"branch\": \"$branch\","
      echo "      \"issue\": \"${issue}\","
      echo "      \"status\": \"$status\","
      echo "      \"changes\": $changes,"
      echo "      \"last_commit\": \"$last_commit\","
      echo "      \"last_commit_time\": \"$last_commit_time\""
      
      if [[ $i -eq $((${#RESULTS[@]} - 1)) ]]; then
        echo "    }"
      else
        echo "    },"
      fi
    done
    
    echo "  ]"
    echo "}"
    ;;
    
  *)  # table format by default
    printf "%-30s %-25s %-10s %-15s %-30s\n" "WORKTREE" "BRANCH" "ISSUE" "STATUS" "LAST COMMIT"
    printf "%-30s %-25s %-10s %-15s %-30s\n" "$(printf '%0.s-' {1..30})" "$(printf '%0.s-' {1..25})" "$(printf '%0.s-' {1..10})" "$(printf '%0.s-' {1..15})" "$(printf '%0.s-' {1..30})"
    
    for result in "${RESULTS[@]}"; do
      IFS='|' read -r name branch issue status changes last_commit last_commit_time <<< "$result"
      name=${name#isolated-pymcp-}
      
      printf "%-30s %-25s %-10s %-15s %-30s\n" "$name" "$branch" "${issue:--}" "$status" "$last_commit_time"
    done
    
    # Show detailed changes if requested
    if [[ "$SHOW_CHANGES" == true ]]; then
      echo ""
      for ((i=0; i<${#RESULTS[@]}; i++)); do
        IFS='|' read -r name branch issue status changes last_commit last_commit_time <<< "${RESULTS[$i]}"
        worktree="${CLAUDE_WORKTREES[$i]}"
        
        if [[ $changes -gt 0 ]]; then
          echo "Changes in $name:"
          (cd "$worktree" && git status --short)
          echo ""
        fi
      done
    fi
    ;;
esac