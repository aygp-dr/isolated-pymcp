# Claude Code Commands

This directory contains standard command templates for use with Claude Code. These commands provide structured templates for common development tasks.

## Installation

To install these commands to your local Claude Code commands directory:

```bash
# Make the script executable
chmod +x .claude/install-commands.sh

# Run the installation script
./.claude/install-commands.sh
```

This script will copy the command files to `~/.claude/commands/`, removing the `user:` prefix from the filenames.

## Available Commands

- `/user:security-review` - Perform a thorough security review of the codebase
- `/user:security-review-full` - Perform an in-depth comprehensive security review
- `/user:mise-en-place` - Organize workspace and ensure everything is in a clean state
- `/user:check-filename-consistency` - Verify naming conventions across files
- `/user:lint-code` - Run comprehensive code quality checks
- `/user:lint-fix` - Fix linting issues automatically
- `/user:generate-docs` - Create or update project documentation
- `/user:doc-align` - Align documentation across files
- `/user:issue-triage` - Triage and manage GitHub issues
- `/user:validate-issue-labels` - Validate issue labels against standards

## Usage

To use these commands with Claude Code:

1. Run the Claude Code CLI and connect to this repository
2. Enter the command (e.g., `/user:security-review`)
3. Claude will execute the command according to its template

## Adding New Commands

To add a new command:

1. Create a new markdown file in `.claude/commands/` with the format `user:command-name.md`
2. Structure the command with clear instructions and tasks
3. Use markdown formatting for better readability
4. Add the new command to this README

## Best Practices

- Keep commands focused on a single responsibility
- Include clear success criteria
- Provide structured output formats
- Document any required context or prerequisites