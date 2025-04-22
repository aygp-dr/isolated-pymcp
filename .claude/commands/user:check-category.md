# Check Category

Apply all rules from a specific category to the codebase. This command validates your code against a group of related rules.

## Usage

```
/user:check-category CATEGORY [FILE_PATTERN]
```

Parameters:
- `CATEGORY`: The rule category to check (style, security, performance, testing, documentation)
- `FILE_PATTERN` (optional): A glob pattern to limit which files to check (e.g., `*.py`)

## Workflow

1. Load all rules from the specified category
2. Find all relevant files matching the pattern (or all supported files if no pattern)
3. Apply each rule to the appropriate files
4. Generate a consolidated report of all rule violations
5. Provide recommendations prioritized by severity

## Example

```
/user:check-category security scripts/*.sh
```

This will check all shell scripts against all security rules.

## Output Format

The output will include:
- Summary of the category and rules applied
- List of files checked
- Violations grouped by rule, with line numbers
- Suggested fixes for critical and high severity issues
- Summary statistics by severity level
- Recommended next steps