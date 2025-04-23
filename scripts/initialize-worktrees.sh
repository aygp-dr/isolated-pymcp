#!/bin/bash
# initialize-worktrees.sh - Set up development environment for each worktree

set -e

WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"
WORKTREES=(
  "isolated-pymcp-readme"
  "isolated-pymcp-mcp-servers"
  "isolated-pymcp-tests"
  "isolated-pymcp-docs"
  "isolated-pymcp-ci"
)

# For each worktree
for worktree in "${WORKTREES[@]}"; do
  echo "===== Setting up $worktree ====="
  cd "$WORKTREES_DIR/$worktree"
  
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
echo "You can now run Claude Code in each worktree:"
echo "cd $WORKTREES_DIR/isolated-pymcp-readme && claude"
echo "cd $WORKTREES_DIR/isolated-pymcp-mcp-servers && claude"
echo "cd $WORKTREES_DIR/isolated-pymcp-tests && claude"
echo "cd $WORKTREES_DIR/isolated-pymcp-docs && claude"
echo "cd $WORKTREES_DIR/isolated-pymcp-ci && claude"