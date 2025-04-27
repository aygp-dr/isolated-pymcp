# Claude Code Project Commands

This directory contains Claude Code custom command configurations for this project. These commands help standardize interactions with Claude Code agents.

## Command List

- **code:analyze**: Perform comprehensive codebase analysis
- **code:diagram**: Create diagrams of system architecture or components
- **code:hotspots**: Analyze code complexity and improvement areas
- **code:review**: Review code changes for quality and issues
- **code:doc**: Generate documentation for components
- **code:security**: Perform security analysis of components
- **code:visualize**: Create visual representations of code structure
- **code:optimize**: Find optimization opportunities
- **code:test**: Generate test cases for components

## Usage

These commands can be used in Claude Code by typing:

```
/project:code:analyze
/project:code:diagram <type>
/project:code:hotspots
/project:code:review <files>
/project:code:doc <component>
/project:code:security <component>
/project:code:visualize <item>
/project:code:optimize <component>
/project:code:test <component>
```

## Configuration

Command definitions are stored in `.claude/commands/` directory. Each command has its own markdown file that defines the prompt for Claude when the command is invoked.

## User Commands

The repository also includes standard user commands:

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

## Static Analysis

The commands reference static analysis data in:
- `.claude/.cache/repo-context.json`: Repository context information
- `.claude/.cache/diagrams/`: Diagram references
- `.claude/.cache/analysis/hotspots.json`: Code complexity hotspots

You can modify command definitions in the `.claude/commands/` directory to customize their behavior.