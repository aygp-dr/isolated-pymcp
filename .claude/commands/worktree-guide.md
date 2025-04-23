# Git Worktrees Guide for Claude Code

This guide explains how to use Git worktrees with Claude Code to work on multiple tasks simultaneously while maintaining isolated development environments.

## What are Git Worktrees?

Git worktrees allow you to check out multiple branches from the same repository into separate directories. Each worktree has its own working directory with isolated files, while sharing the same Git history. This feature is perfect for:

- Working on multiple features simultaneously
- Creating a bugfix while in the middle of feature development
- Maintaining separate environments for different tasks
- Running parallel Claude Code sessions on related tasks

## Benefits of Worktrees with Claude Code

- **Isolation**: Changes in one worktree don't affect others
- **Context Preservation**: Claude maintains understanding across worktrees
- **Productivity**: No need to stash changes when switching tasks
- **Parallelism**: Run multiple Claude Code sessions with different goals

## Available Commands

Claude Code supports the following commands for working with Git worktrees:

- [/new-worktree](new-worktree.md) - Create a new worktree and branch
- [/list-worktrees](list-worktrees.md) - List all worktrees for this repository
- [/switch-worktree](switch-worktree.md) - Switch Claude's context to a different worktree
- [/delete-worktree](delete-worktree.md) - Remove a worktree when you're done with it

## Workflow Examples

### Example 1: Feature Development While Fixing a Bug

1. Start working on a feature in your main worktree
2. Discover a critical bug that needs immediate attention
3. Create a bugfix worktree: `/new-worktree fix/critical-bug main`
4. Fix the bug in the new worktree and commit the changes
5. Switch back to your feature: `/switch-worktree main`
6. Continue feature development without losing context
7. Delete the bugfix worktree when done: `/delete-worktree fix/critical-bug`

### Example 2: Working on Related Features

1. Create worktrees for each feature:
   ```
   /new-worktree feature/user-authentication
   /new-worktree feature/user-profile
   /new-worktree feature/user-settings
   ```
2. Run separate Claude Code sessions in each worktree directory
3. Develop each feature independently
4. Seamlessly share knowledge between the related features
5. Delete worktrees as you complete each feature

### Example 3: Working on Open Issues

1. List open issues with `/list-issues`
2. Create worktrees for each issue you want to work on:
   ```
   /new-worktree feat/documentation --issue=45
   /new-worktree enhance/mcp-servers --issue=46
   ```
3. Work on each issue in its own environment
4. Switch between worktrees as needed: `/switch-worktree 2`
5. Clean up when issues are closed: `/delete-worktree feat/documentation`

## Best Practices

1. **Use descriptive branch names** that reflect the purpose of the worktree
2. **Follow branch naming conventions** (e.g., feature/, fix/, docs/)
3. **Initialize the environment** in each worktree to ensure consistency
4. **Commit changes before switching** worktrees to avoid confusion
5. **Delete worktrees when done** to keep your project organized
6. **Use git fetch often** to keep all worktrees up to date

## Worktree Directory Structure

By default, worktrees are created in sibling directories following this structure:

```
/path/to/your/repository               # Main worktree (original repository)
/path/to/your/repository-feature-name  # Feature worktree
/path/to/your/repository-bugfix        # Bugfix worktree
```

You can customize this structure using the `.claude/worktree-config.yaml` file.

## Troubleshooting

- **"Cannot create worktree: branch already exists"** - Use a different branch name or delete the existing branch
- **"Cannot delete worktree: contains modified files"** - Commit or stash changes first, or use `--force`
- **"Issues switching worktree context"** - Ensure all file paths are correct and the worktree exists

## References

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Claude Code Parallel Sessions Tutorial](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials#run-parallel-claude-code-sessions-with-git-worktrees)
- [RFC: `/new-worktree` Command for Claude Code (#66)](https://github.com/aygp-dr/isolated-pymcp/issues/66)
- [Setup git worktrees for parallel development (#71)](https://github.com/aygp-dr/isolated-pymcp/issues/71)