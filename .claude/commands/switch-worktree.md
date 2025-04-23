# `/switch-worktree` - Switch to a different Git worktree

Switch Claude's context to a different Git worktree while maintaining your conversation history.

## Syntax

```
/switch-worktree <worktree-identifier> [options]
```

Where:
- `<worktree-identifier>` can be a branch name, directory path, or worktree number (from `/list-worktrees`)

## Options

- `--maintain-files` - Keep currently open files visible in the new worktree context
- `--verbose` - Show detailed information during the switch process
- `--help` - Display this help information

## Description

The `/switch-worktree` command allows you to switch Claude's context from one worktree to another without losing your conversation history. This enables seamless context switching between different development tasks.

When you run this command, Claude will:

1. Save its current context and conversation history
2. Update its file system view to the new worktree location
3. Load the Git branch and status from the new worktree
4. Transfer relevant context about the codebase to the new environment
5. Continue the conversation with awareness of the new worktree

## Examples

### Switch by branch name

```
/switch-worktree feature/update-readme
```

Switches Claude's context to the worktree containing the `feature/update-readme` branch.

### Switch by directory path

```
/switch-worktree /home/jwalsh/projects/aygp-dr/worktrees/isolated-pymcp-docs
```

Switches Claude's context to the worktree at the specified directory path.

### Switch by worktree number

```
/switch-worktree 3
```

Switches to the third worktree in the list shown by `/list-worktrees`.

## Related Commands

- `/new-worktree` - Create a new worktree
- `/list-worktrees` - List all available worktrees
- `/delete-worktree` - Remove a worktree

## Notes

- Claude maintains awareness of the relationship between all worktrees
- Your conversation history is preserved when switching between worktrees
- File operations will affect only the currently active worktree
- Use `/list-worktrees` to see which worktree is currently active

## See Also

- [Claude Code Parallel Sessions Tutorial](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials#run-parallel-claude-code-sessions-with-git-worktrees)
- [Worktree Management Issue #71](https://github.com/aygp-dr/isolated-pymcp/issues/71)