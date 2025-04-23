#!/usr/bin/env bash
# claude-new-worktree.sh - Create a new git worktree for Claude Code

set -e

# Default values
WORKTREES_DIR="/home/jwalsh/projects/aygp-dr/worktrees"
BRANCH_PREFIX="feature/"
ISSUE_NUMBER=""
INITIALIZE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      echo "Usage: claude-new-worktree.sh NAME [OPTIONS]"
      echo "Create a new git worktree for use with Claude Code"
      echo ""
      echo "Options:"
      echo "  -b, --branch NAME     Branch name (default: derived from worktree name)"
      echo "  -p, --prefix PREFIX   Branch name prefix (default: feature/)"
      echo "  -i, --issue NUMBER    Associate with GitHub issue number"
      echo "  --init                Run initialization script after creation"
      echo "  -d, --dir PATH        Custom worktrees directory (default: $WORKTREES_DIR)"
      echo "  -h, --help            Show this help message"
      echo ""
      echo "Example:"
      echo "  claude-new-worktree.sh update-readme --issue 42 --init"
      exit 0
      ;;
    -b|--branch)
      BRANCH_NAME="$2"
      shift 2
      ;;
    -p|--prefix)
      BRANCH_PREFIX="$2"
      shift 2
      ;;
    -i|--issue)
      ISSUE_NUMBER="$2"
      shift 2
      ;;
    --init)
      INITIALIZE=true
      shift
      ;;
    -d|--dir)
      WORKTREES_DIR="$2"
      shift 2
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
  echo "Run 'claude-new-worktree.sh --help' for usage information"
  exit 1
fi

# Determine branch name if not specified
if [[ -z "$BRANCH_NAME" ]]; then
  BRANCH_NAME="${BRANCH_PREFIX}${WORKTREE_NAME}"
fi

# Set up paths
REPO_ROOT="$(git rev-parse --show-toplevel)"
WORKTREE_PATH="${WORKTREES_DIR}/isolated-pymcp-${WORKTREE_NAME}"

# Create directory if it doesn't exist
mkdir -p "$WORKTREES_DIR"

# Check if worktree already exists
if [[ -d "$WORKTREE_PATH" ]]; then
  echo "Error: Worktree directory already exists at $WORKTREE_PATH"
  exit 1
fi

# Create the branch and worktree
echo "Creating new worktree with:"
echo "  Name:       isolated-pymcp-${WORKTREE_NAME}"
echo "  Branch:     ${BRANCH_NAME}"
echo "  Path:       ${WORKTREE_PATH}"
if [[ -n "$ISSUE_NUMBER" ]]; then
  echo "  Issue:      #${ISSUE_NUMBER}"
fi

# Check if the branch exists
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
  # Branch exists, create worktree from it
  echo "Branch '${BRANCH_NAME}' already exists, creating worktree..."
  git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
  # Create new branch and worktree
  echo "Creating new branch '${BRANCH_NAME}' and worktree..."
  git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH"
fi

# Create .claude directory in the worktree
mkdir -p "${WORKTREE_PATH}/.claude"

# Add issue reference if applicable
if [[ -n "$ISSUE_NUMBER" ]]; then
  echo "Adding issue reference to worktree..."
  echo "Related to issue #${ISSUE_NUMBER}" > "${WORKTREE_PATH}/.claude/issue.md"
fi

# Run initialization if requested
if [[ "$INITIALIZE" = true ]]; then
  echo "Initializing worktree environment..."
  if [[ -f "${REPO_ROOT}/scripts/initialize-worktrees.sh" ]]; then
    WORKTREE="isolated-pymcp-${WORKTREE_NAME}" bash "${REPO_ROOT}/scripts/initialize-worktrees.sh"
  else
    echo "Warning: Initialization script not found. Creating basic structure."
    mkdir -p "${WORKTREE_PATH}/algorithms" "${WORKTREE_PATH}/scripts" "${WORKTREE_PATH}/data"
  fi
fi

echo ""
echo "Worktree created successfully at ${WORKTREE_PATH}"
echo ""
echo "To start working in this worktree:"
echo "  cd ${WORKTREE_PATH}"
echo "  claude"
echo ""
echo "To list all worktrees:"
echo "  claude-list-worktrees.sh"