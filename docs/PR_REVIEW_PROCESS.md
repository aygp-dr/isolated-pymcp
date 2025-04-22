# PR Review Process

This document outlines the pull request review process for the isolated-pymcp project.

## Configuration File

The PR review system is configured using `.claude/pr-review-config.json`, which defines:

- Available reviewer roles and their responsibilities
- File patterns relevant to each role
- Role-specific commands to run during review
- Critical paths requiring additional review attention

## Reviewer Roles

Each PR should be reviewed by at least one person in an appropriate role:

1. **Engineer** - Technical implementation details
   - Code quality and correctness
   - Test coverage
   - Adherence to Python standards
   - Performance considerations
   
2. **SRE (Site Reliability Engineer)** - Operational concerns
   - Performance benchmarking
   - Resource utilization
   - Error handling and recovery
   - Monitoring and observability
   
3. **Manager** - Project management aspects
   - Documentation completeness
   - Feature alignment with requirements
   - Timeline and sprint planning
   - Cross-team coordination
   
4. **Director** - Strategic alignment
   - Architectural consistency
   - Long-term maintainability
   - Strategic objectives
   - Cross-project dependencies

## Critical Paths

Certain files or directories require special review attention:

1. **Security-related files** - Require reviews from both Engineer and SRE roles
   - Paths matching: `**/security/**`, `**/*security*`
   - Minimum approvals: 2

2. **Architecture files** - Require review from Director role
   - Paths matching: `architecture.mmd`, `diagrams/**`
   - Minimum approvals: 1

## Review Process

1. **PR Creation**
   - Create PR with detailed description
   - Link related issues
   - Add appropriate labels

2. **CI/CD Checks**
   - Automated tests run
   - Linting and type checking
   - Test coverage validation

3. **Role-Based Review**
   - Assign at least one reviewer with appropriate role
   - Use `make review-pr PR=123 ROLE=role_name` to perform role-specific review
   - Each role focuses on their area of expertise

4. **Approval Requirements**
   - At least one approval required before merging
   - Critical changes may require multiple approvals

5. **Merging**
   - PR can be merged once approved
   - Use `make review-pr PR=123 AUTO_MERGE=--auto-merge` for automatic merging after approval

## Using the Review Script

The `scripts/review-pr.sh` script automates much of the review process:

```bash
# Review as an engineer
./scripts/review-pr.sh 123 --reviewer=engineer

# Review as an SRE
./scripts/review-pr.sh 123 --reviewer=sre

# Review and auto-merge (with approval)
./scripts/review-pr.sh 123 --auto-merge --reviewer=manager
```

Or using the Makefile:

```bash
# Review as director
make review-pr PR=123 ROLE=director

# Review and auto-merge after approval
make review-pr PR=123 ROLE=engineer AUTO_MERGE=--auto-merge
```

## Extending the PR Review System

To add a new reviewer role:

1. Edit `.claude/pr-review-config.json` and add the role to the `roles` object:

```json
"new_role": {
  "description": "Role description",
  "responsibilities": [
    "Responsibility 1",
    "Responsibility 2"
  ],
  "filePatterns": [
    "patterns/to/match/*.ext"
  ],
  "commands": [
    "command to run during review"
  ]
}
```

2. To add critical paths requiring additional reviews:

```json
"criticalPaths": {
  "new_critical_area": {
    "paths": ["path/pattern/*"],
    "requiredRoles": ["role1", "role2"],
    "minApprovals": 2
  }
}
```

The review script will automatically pick up these changes when running reviews.