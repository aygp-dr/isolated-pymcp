# `/list-worktrees` - List Git worktrees

Display all Git worktrees associated with the current repository.

## Syntax

```
/list-worktrees [options]
```

## Options

- `--verbose` - Show detailed information about each worktree
- `--filter=PATTERN` - Filter worktrees by name or branch pattern
- `--help` - Display this help information

## Description

The `/list-worktrees` command shows all Git worktrees associated with your repository. This helps you keep track of all the separate working directories you've created for parallel development tasks.

For each worktree, the command displays:
- Worktree path
- Branch name
- Last commit
- Associated issue (if any)
- Status (active/stale)

## Examples

### List all worktrees

```
/list-worktrees
```

Example output:
```
Git Worktrees for isolated-pymcp:

1. /home/jwalsh/projects/aygp-dr/isolated-pymcp [main]
   Last commit: b7ac488 (2 hours ago) - feat: add worktree initialization script
   Status: Active (current)

2. /home/jwalsh/projects/aygp-dr/worktrees/isolated-pymcp-readme [feature/update-readme]
   Last commit: 2598fb0 (1 day ago) - docs: simplify CLAUDE.md with concise guidelines
   Associated issue: #71
   Status: Active

3. /home/jwalsh/projects/aygp-dr/worktrees/isolated-pymcp-mcp-servers [feature/enhance-mcp-servers]
   Last commit: 2598fb0 (1 day ago) - docs: simplify CLAUDE.md with concise guidelines
   Associated issue: #71
   Status: Active

...
```

### Show detailed information

```
/list-worktrees --verbose
```

This will show additional information like environment setup status, active files, and more.

### Filter worktrees by pattern

```
/list-worktrees --filter=docs
```

This will only show worktrees with "docs" in their path or branch name.

## Related Commands

- `/new-worktree` - Create a new worktree
- `/switch-worktree` - Switch to a different worktree
- `/delete-worktree` - Remove a worktree

## See Also

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Worktree Management Issue #71](https://github.com/aygp-dr/isolated-pymcp/issues/71)