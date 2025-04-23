#!/usr/bin/env bash
# claude-worktree.sh - Main wrapper for Claude Code worktree commands

set -e

# Default values
COMMAND=""
WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"

# Display help
show_help() {
  echo "Claude Code Worktree Manager"
  echo ""
  echo "Usage: claude-worktree.sh COMMAND [ARGS]"
  echo ""
  echo "Commands:"
  echo "  new NAME [OPTIONS]       Create a new worktree"
  echo "  list [OPTIONS]           List available worktrees"
  echo "  switch NAME              Switch to a worktree"
  echo "  delete NAME [OPTIONS]    Delete a worktree"
  echo "  status [OPTIONS]         Show status of all worktrees"
  echo "  init [NAME]              Initialize worktree environment(s)"
  echo "  help                     Show this help message"
  echo ""
  echo "For command-specific help:"
  echo "  claude-worktree.sh COMMAND --help"
  echo ""
  echo "Examples:"
  echo "  claude-worktree.sh new update-readme --issue 42 --init"
  echo "  claude-worktree.sh list --format json"
  echo "  claude-worktree.sh switch docs"
  echo "  claude-worktree.sh status --changes"
  echo "  claude-worktree.sh delete old-feature --delete-branch"
}

# Get command (first argument)
if [[ $# -gt 0 ]]; then
  COMMAND="$1"
  shift
else
  show_help
  exit 1
fi

# Execute the appropriate command
case "$COMMAND" in
  "new"|"create")
    exec claude-new-worktree.sh "$@"
    ;;
  "list"|"ls")
    exec claude-list-worktrees.sh "$@"
    ;;
  "switch"|"cd"|"use")
    exec claude-switch-worktree.sh "$@"
    ;;
  "delete"|"remove"|"rm")
    exec claude-delete-worktree.sh "$@"
    ;;
  "status"|"st")
    exec claude-worktree-status.sh "$@"
    ;;
  "init"|"initialize")
    if [[ $# -gt 0 ]]; then
      WORKTREE="isolated-pymcp-$1" ./scripts/initialize-worktrees.sh
    else
      ./scripts/initialize-worktrees.sh
    fi
    ;;
  "help"|"-h"|"--help")
    show_help
    ;;
  *)
    echo "Error: Unknown command '$COMMAND'"
    echo ""
    show_help
    exit 1
    ;;
esac