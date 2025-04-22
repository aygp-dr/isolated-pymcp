# Claude Code Rules

This directory contains structured rules for Claude Code to enforce code quality and style guidelines.

## Directory Structure

Rules are organized by category:

```
.claude/rules/
├── style/         # Code style and formatting rules
├── security/      # Security best practices
├── performance/   # Performance optimization rules
├── testing/       # Testing requirements and practices
└── documentation/ # Documentation standards
```

## Rule Format

Each rule is stored in a markdown file with metadata in a YAML frontmatter:

```markdown
---
title: Rule Title
category: style|security|performance|testing|documentation
severity: critical|high|medium|low
language: python|bash|javascript|typescript|multiple
---

# Rule Title

## Rule
Description of the rule...

## Examples
Example code...

## Rationale
Why this rule is important...

## References
Links to relevant documentation...
```

## Using Rules

Claude Code can analyze your code against these rules:

1. For a specific rule: `/check-rule style/python-naming`
2. For a category: `/check-category security`
3. For all rules: `/check-all-rules`

## Adding New Rules

To add a new rule:

1. Identify the appropriate category
2. Create a new markdown file with the rule name
3. Include YAML frontmatter with metadata
4. Follow the rule format with sections for Rule, Examples, Rationale, and References
5. Add examples of both correct and incorrect code

## Rule Enforcement

Rules with higher severity should be enforced more strictly. Critical and high severity rules should be considered requirements, while medium and low severity rules are recommendations.