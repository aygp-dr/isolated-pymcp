# `/worktree` Command

Manage Git worktrees for isolated feature development.

## Syntax

```
/worktree [SUBCOMMAND] [OPTIONS]
```

## Description

The `/worktree` command helps manage Git worktrees, allowing you to work on multiple features concurrently without switching branches in your main repository.

## Subcommands

- `new NAME [--issue NUMBER] [--init]`: Create a new worktree
- `list [--format FORMAT]`: List all worktrees
- `status [--changes]`: Show status of all worktrees
- `delete NAME [--branch]`: Delete a worktree
- `switch NAME`: Show how to switch to a worktree
- `init [NAME]`: Initialize worktree environment(s)

## Options

### New Worktree
- `NAME`: Feature name (required)
- `--issue NUMBER`: Associate with GitHub issue
- `--init`: Initialize the worktree after creation

### List Worktrees
- `--format FORMAT`: Output format (default: table)

### Worktree Status
- `--changes`: Show only worktrees with changes

### Delete Worktree
- `NAME`: Feature name to delete (required)
- `--branch`: Delete branch as well

### Initialize Worktree
- `NAME`: Specific worktree to initialize (optional)

## Examples

```
/worktree new headless-claude --issue 31
/worktree list
/worktree status --changes
/worktree delete old-feature --branch
/worktree switch headless-claude
/worktree init
```

## Implementation

This command uses the following scripts:
- `scripts/claude-new-worktree.sh`
- `scripts/claude-list-worktrees.sh`
- `scripts/claude-worktree-status.sh`
- `scripts/claude-delete-worktree.sh`
- `scripts/claude-switch-worktree.sh`
- `scripts/initialize-worktrees.sh`

These are wrapped by the Makefile targets:
- `make worktree-new NAME=feature-name [ISSUE=42] [INIT=1]`
- `make worktree-list [FORMAT=json]`
- `make worktree-status [CHANGES=1]`
- `make worktree-delete NAME=feature-name [BRANCH=1]`
- `make worktree-switch NAME=feature-name`
- `make worktree-init [NAME=feature-name]`