# `/delete-worktree` - Remove a Git worktree

Remove a Git worktree when you're done with it.

## Syntax

```
/delete-worktree <worktree-identifier> [options]
```

Where:
- `<worktree-identifier>` can be a branch name, directory path, or worktree number (from `/list-worktrees`)

## Options

- `--force` - Force deletion even if the worktree has untracked changes
- `--keep-branch` - Don't delete the associated branch
- `--help` - Display this help information

## Description

The `/delete-worktree` command safely removes a Git worktree when you no longer need it. This helps keep your development environment clean and organized after completing a task.

When you run this command, Claude will:

1. Check if the worktree has any uncommitted changes
2. Remove the worktree directory
3. Optionally delete the associated branch (unless `--keep-branch` is specified)
4. Update Claude's internal tracking of worktrees

## Examples

### Delete by branch name

```
/delete-worktree feature/update-readme
```

Removes the worktree containing the `feature/update-readme` branch and deletes the branch.

### Delete by directory path

```
/delete-worktree /home/jwalsh/projects/aygp-dr/worktrees/isolated-pymcp-docs
```

Removes the worktree at the specified directory path.

### Delete by worktree number

```
/delete-worktree 3
```

Removes the third worktree in the list shown by `/list-worktrees`.

### Delete but keep the branch

```
/delete-worktree feature/user-auth --keep-branch
```

Removes the worktree but keeps the associated branch in the Git repository.

## Related Commands

- `/new-worktree` - Create a new worktree
- `/list-worktrees` - List all available worktrees
- `/switch-worktree` - Switch to a different worktree

## Notes

- You cannot delete the main worktree (the original repository)
- Claude will warn you before deleting a worktree with uncommitted changes
- Use `--force` with caution, as it may result in loss of uncommitted work
- If you're currently in the worktree being deleted, Claude will switch to the main worktree

## See Also

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Worktree Management Issue #71](https://github.com/aygp-dr/isolated-pymcp/issues/71)