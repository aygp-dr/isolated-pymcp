#!/usr/bin/env bash
# initialize-worktrees.sh - Set up development environment for each worktree

set -e

WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"

# Allow specifying a single worktree
if [[ -n "$WORKTREE" ]]; then
  WORKTREES=("$WORKTREE")
else
  # Use all worktrees if not specified
  if command -v claude-list-worktrees.sh >/dev/null 2>&1; then
    # Use the list-worktrees script if available
    mapfile -t WORKTREES < <(claude-list-worktrees.sh --format simple)
  else
    # Default list if we're bootstrapping
    WORKTREES=(
      "isolated-pymcp-readme"
      "isolated-pymcp-mcp-servers"
      "isolated-pymcp-tests"
      "isolated-pymcp-docs"
      "isolated-pymcp-ci"
    )
  fi
fi

# For each worktree
for worktree in "${WORKTREES[@]}"; do
  echo "===== Setting up $worktree ====="
  
  # Check if directory exists
  if [[ ! -d "$WORKTREES_DIR/$worktree" ]]; then
    echo "Warning: Worktree directory not found: $WORKTREES_DIR/$worktree"
    continue
  fi
  
  cd "$WORKTREES_DIR/$worktree"
  
  # Copy claude command documentation files if they exist in the main repo
  REPO_ROOT="$(git rev-parse --show-toplevel)"
  if [[ -d "$REPO_ROOT/.claude/commands" ]]; then
    echo "Copying Claude command documentation..."
    mkdir -p .claude/commands
    cp -a "$REPO_ROOT/.claude/commands/"* .claude/commands/ 2>/dev/null || true
  fi
  
  # Ensure required directories exist
  echo "Creating required directories..."
  mkdir -p algorithms scripts analysis_results emacs data/{memory,filesystem,github} .claude .vscode
  
  # Install development tools
  echo "Installing development tools..."
  if ! make install-dev-tools; then
    echo "Warning: Failed to install development tools in $worktree"
  fi
  
  echo "Worktree $worktree setup complete!"
  echo ""
done

echo "All worktrees initialized successfully!"
echo ""
echo "You can now run Claude Code in each worktree using:"
echo "  claude-switch-worktree.sh <worktree-name>"
echo ""
echo "To see all available worktrees:"
echo "  claude-list-worktrees.sh"
echo ""
echo "To check status of all worktrees:"
echo "  claude-worktree-status.sh --changes"