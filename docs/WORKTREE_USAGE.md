# Git Worktree Usage Guide for Claude Code

This guide explains how to use Git worktrees with Claude Code for parallel development on multiple features/issues simultaneously.

## Overview

Git worktrees enable you to check out multiple branches from the same repository in separate directories. This allows you to work on different features concurrently without needing to commit, stash, or switch branches in a single working directory.

In this project, we've created a set of tools to make working with worktrees and Claude Code seamless.

## Basic Commands

### 1. Creating a New Worktree

```bash
# Using the command-line script
./claude-worktree new feature-name --issue 42 --init

# Using Make
make worktree-new NAME=feature-name ISSUE=42 INIT=1
```

Options:
- `--issue NUMBER` - Associate the worktree with a GitHub issue
- `--init` - Initialize the worktree with the required project structure
- `--branch NAME` - Specify a custom branch name (default: `feature/feature-name`)
- `--prefix PREFIX` - Change the branch name prefix (default: `feature/`)

### 2. Listing Worktrees

```bash
# Using the command-line script
./claude-worktree list [--format table|json|simple]

# Using Make
make worktree-list [FORMAT=json]
```

### 3. Checking Worktree Status

```bash
# Using the command-line script
./claude-worktree status [--changes]

# Using Make
make worktree-status [CHANGES=1]
```

The `--changes` flag shows details of uncommitted changes in each worktree.

### 4. Switching to a Worktree

```bash
# Using the command-line script
./claude-worktree switch feature-name

# Using Make
make worktree-switch NAME=feature-name
```

This will display instructions on how to switch to the specified worktree.

### 5. Deleting a Worktree

```bash
# Using the command-line script
./claude-worktree delete feature-name [--delete-branch]

# Using Make
make worktree-delete NAME=feature-name [BRANCH=1]
```

The `--delete-branch` flag also deletes the associated Git branch.

### 6. Initializing Worktree Environment

```bash
# Using the command-line script
./claude-worktree init [feature-name]

# Using Make
make worktree-init [NAME=feature-name]
```

Without a name, this initializes all worktrees.

## Workflow Example

Here's an example workflow for working on multiple features simultaneously:

1. **Create worktrees for each feature**

```bash
make worktree-new NAME=update-readme ISSUE=42 INIT=1
make worktree-new NAME=improve-tests ISSUE=43 INIT=1
```

2. **Work on each feature in separate terminal sessions**

```bash
# Terminal 1
cd /home/jwalsh/projects/aygp-dr/worktrees/isolated-pymcp-update-readme
claude

# Terminal 2
cd /home/jwalsh/projects/aygp-dr/worktrees/isolated-pymcp-improve-tests
claude
```

3. **Check status of all worktrees**

```bash
# From main repository
make worktree-status CHANGES=1
```

4. **Clean up when a feature is complete**

```bash
# After merging the PR for a completed feature
make worktree-delete NAME=update-readme BRANCH=1
```

## Integration with Claude Code

Each worktree is a standalone working directory with its own Claude Code context. When working with Claude Code:

1. Claude will maintain a separate context for each worktree
2. Use the `.claude/commands/` directory to access worktree-related commands
3. Branch information is preserved in each worktree

## Tips and Best Practices

- Create a new worktree for each feature or issue you're working on
- Use `--issue` to associate worktrees with GitHub issues for better tracking
- Always use `--init` when creating new worktrees to ensure proper setup
- Use `worktree-status` regularly to keep track of all your work
- Delete worktrees when you're done with them to keep your workspace clean
- Use the provided Make targets for consistent worktree management

## Troubleshooting

If you encounter issues with worktrees:

1. Ensure the worktree directory exists:
   ```bash
   make worktree-list
   ```

2. Check for uncommitted changes before deleting:
   ```bash
   make worktree-status CHANGES=1
   ```

3. Force delete if needed (BE CAREFUL - this can lose work):
   ```bash
   git worktree remove --force /path/to/worktree
   ```

4. Reinitialize if worktree environment is incomplete:
   ```bash
   make worktree-init NAME=feature-name
   ```

## Related Documentation

- Git worktree official documentation: `git help worktree`
- Claude Code slash commands: See `.claude/commands/` directory
- GitHub Issue #66: RFC for `/new-worktree` command for Claude Code
- GitHub Issue #71: Setup of worktrees for parallel development