# `/new-worktree` - Create and manage Git worktrees

Create a new Git worktree with an isolated branch while maintaining Claude's context.

## Syntax

```
/new-worktree <branch-name> [base-branch] [options]
```

Where:
- `<branch-name>` is the name of the new branch to create (required)
- `[base-branch]` is the branch to base the new worktree on (defaults to current branch)
- `[options]` are additional configuration options

## Options

- `--dir=PATH` - Specify a custom directory path for the new worktree
- `--issue=NUMBER` - Associate this worktree with a GitHub issue number
- `--no-setup` - Skip automatic environment setup
- `--help` - Display this help information

## Description

The `/new-worktree` command streamlines the process of creating and working with Git worktrees. It enables you to work on multiple features or fixes simultaneously without switching branches in your main repository.

When you run this command, Claude will:

1. Create a new branch based on the specified base branch
2. Set up a worktree in a sibling directory using this branch
3. Initialize the development environment in the new worktree
4. Maintain context awareness between all related worktrees

## Examples

### Create a worktree for a new feature

```
/new-worktree feature/user-authentication
```

This creates a new branch called `feature/user-authentication` based on your current branch, sets up a worktree at `../isolated-pymcp-user-authentication`, and initializes the development environment.

### Create a worktree based on a specific branch

```
/new-worktree fix/login-bug main
```

This creates a new branch called `fix/login-bug` based on the `main` branch, and sets up a worktree for it.

### Create a worktree with custom options

```
/new-worktree refactor/api-endpoints develop --dir=../custom-path --no-setup
```

This creates a new branch called `refactor/api-endpoints` based on the `develop` branch, sets up a worktree at `../custom-path`, and skips environment setup.

### Create a worktree linked to a GitHub issue

```
/new-worktree feat/dark-mode --issue=42
```

This creates a new branch and worktree for implementing the feature described in issue #42, and adds a reference to the issue in the commit messages.

## Related Commands

- `/list-worktrees` - List all worktrees associated with this repository
- `/switch-worktree` - Switch Claude's context to a different worktree
- `/delete-worktree` - Remove a worktree when you're done with it

## Environment Setup

By default, the command will detect your project type and set up the appropriate development environment:

- **Python**: Creates/activates virtual environment, installs dependencies
- **JavaScript/Node.js**: Runs `npm install` or `yarn install`
- **Go**: Runs `go mod download`
- **Other**: Executes setup commands defined in `.claude/worktree-config.yaml`

## Configuration

You can customize the behavior of this command by creating a `.claude/worktree-config.yaml` file:

```yaml
# Example configuration
default_base_branch: develop
worktree_directory: ../worktrees
naming_convention: "${repo_name}-${branch_name}"
setup_commands:
  python:
    - "python -m venv .venv"
    - ".venv/bin/pip install -e ."
  node:
    - "npm install"
```

## Notes

- Claude maintains context across all worktrees for the same repository
- Each worktree has its own isolated file state
- Changes made in one worktree won't affect others
- All worktrees share the same Git history and remote connections

## See Also

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- [Claude Code Parallel Sessions Tutorial](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/tutorials#run-parallel-claude-code-sessions-with-git-worktrees)
- [Worktree Management Issue #71](https://github.com/aygp-dr/isolated-pymcp/issues/71)