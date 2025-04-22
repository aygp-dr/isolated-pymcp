# Check Rule

Apply a specific Claude Code rule to the codebase. This command allows you to validate your code against individual rules from the rule system.

## Usage

```
/user:check-rule RULE_ID [FILE_PATTERN]
```

Parameters:
- `RULE_ID`: The identifier of the rule (e.g., `style/python-naming`)
- `FILE_PATTERN` (optional): A glob pattern to limit which files to check (e.g., `*.py`)

## Workflow

1. Load the specified rule from the `.claude/rules/` directory
2. Find all relevant files matching the pattern (or all supported files if no pattern)
3. Apply the rule to each file
4. Generate a report of compliance or violations
5. Provide specific recommendations for fixing violations

## Example

```
/user:check-rule documentation/docstrings algorithms/*.py
```

This will check all Python files in the algorithms directory against the docstrings rule.

## Output Format

The output will include:
- Summary of the rule being applied
- Files checked and their compliance status
- Specific violations with line numbers
- Suggested fixes for violations
- Overall compliance score