# Dependency Type Management

## Overview

Beads supports a sophisticated dependency management system that allows you to model relationships between issues. This enables proper task planning, dependency resolution, and ensures work is done in the correct order.

## Dependency Types

### 1. Blocks (Hard Dependency)

**Type**: `blocks`

**Description**: A blocking dependency represents a hard constraint where the dependent issue cannot be started or completed until the blocking issue is resolved.

**Use Cases**:
- Technical dependencies (e.g., API must be built before UI can consume it)
- Sequential implementation requirements
- Prerequisite tasks that must complete first

**Example**:
```bash
# Issue A blocks Issue B (B depends on A)
bd dep add issue-b issue-a --type blocks

# Issue B cannot be marked as ready until Issue A is complete
```

**Resolution Behavior**:
- Blocked issues appear in `bd blocked` output
- Blocked issues are excluded from `bd ready` until all blocking dependencies are resolved
- Blocking relationships create a strict ordering constraint

### 2. Related (Soft Connection)

**Type**: `related`

**Description**: A related dependency indicates that two issues are connected but one does not block the other. This is useful for tracking issues that should be considered together or have shared context.

**Use Cases**:
- Similar features or bug fixes
- Issues that share common code areas
- Cross-cutting concerns
- Documentation that references implementation

**Example**:
```bash
# Link two related issues
bd dep add issue-x issue-y --type related

# Both can be worked on independently
```

**Resolution Behavior**:
- Related issues do not affect `bd ready` or `bd blocked`
- Useful for discovery and context during implementation
- Helps maintainers understand issue relationships

### 3. Discovered-From (Traceability Chain)

**Type**: `discovered-from`

**Description**: A traceability dependency tracks the origin of an issue, creating an audit trail from discovery through implementation. This is particularly valuable for agent-based workflows where issues are discovered dynamically.

**Use Cases**:
- Bugs discovered during feature implementation
- Follow-up tasks identified during code review
- Technical debt found during refactoring
- Research findings that spawn implementation tasks

**Example**:
```bash
# Issue B was discovered while working on Issue A
bd dep add issue-b issue-a --type discovered-from

# Creates a traceability chain: A → B
```

**Resolution Behavior**:
- Discovered-from dependencies do not block work
- Provides historical context and traceability
- Useful for understanding the evolution of the codebase
- Enables tracking of discovery patterns

### 4. Parent-Child (Hierarchical Relationship)

**Type**: `parent-child`

**Description**: A hierarchical dependency that represents a parent-child relationship, typically used for epics and their sub-tasks.

**Use Cases**:
- Epics with sub-tasks
- Large features broken into smaller units
- Milestone tracking

**Example**:
```bash
# Issue A is the parent of Issue B
bd dep add issue-b issue-a --type parent-child
```

**Resolution Behavior**:
- Parent issues track completion of children
- Useful for progress tracking on large initiatives

## Dependency Commands

### Add a Dependency

```bash
# Basic syntax
bd dep add <issue-id> <depends-on-id> [--type TYPE]

# Add blocking dependency (default)
bd dep add isolated-pymcp-123 isolated-pymcp-456

# Add related dependency
bd dep add isolated-pymcp-123 isolated-pymcp-456 --type related

# Add traceability
bd dep add isolated-pymcp-789 isolated-pymcp-123 --type discovered-from
```

### Remove a Dependency

```bash
# Remove a specific dependency
bd dep remove <issue-id> <depends-on-id>
```

### View Dependency Tree

```bash
# Show full dependency tree for an issue
bd dep tree <issue-id>

# Example output shows nested dependencies
```

### Check for Cycles

```bash
# Detect circular dependencies (will cause deadlock)
bd dep cycles

# Should return no cycles for healthy dependency graph
```

### View Blocked Issues

```bash
# List all issues blocked by open dependencies
bd blocked

# Shows issues that cannot proceed due to blocking dependencies
```

## Dependency Resolution

### Ready Work Detection

The `bd ready` command uses dependency information to determine which issues are available to work on:

```bash
bd ready
```

**Ready Criteria**:
1. Status is `open` (not `in_progress`, `done`, or `closed`)
2. All `blocks` type dependencies are resolved (status is `done` or `closed`)
3. Issue is not waiting on any hard constraints

**Not Affected By**:
- `related` dependencies
- `discovered-from` dependencies
- `parent-child` dependencies (for the child)

### Blocked Work Detection

The `bd blocked` command identifies issues that cannot proceed:

```bash
bd blocked
```

**Blocked Criteria**:
1. Issue has at least one `blocks` type dependency
2. At least one blocking dependency has status `open` or `in_progress`

### Cycle Detection

Circular dependencies create deadlock situations where no issue can proceed. The cycle detection algorithm identifies these:

```bash
bd dep cycles
```

**Detection Algorithm**:
- Depth-first search through dependency graph
- Tracks visited nodes and current path
- Reports any cycles found
- Only considers `blocks` type dependencies for cycle detection

## Best Practices

### 1. Use Blocks Sparingly

Only use `blocks` dependencies for true technical constraints. Overuse can create unnecessary bottlenecks.

**Good**:
```bash
# Database schema must exist before migrations
bd dep add migration-task schema-task --type blocks
```

**Bad**:
```bash
# Documentation can be written in parallel with implementation
bd dep add docs-task impl-task --type blocks  # Should use 'related' instead
```

### 2. Create Traceability Chains

Use `discovered-from` to track how issues emerged during development:

```bash
# Found a bug while implementing feature
bd create "Fix null pointer in user service"
bd dep add isolated-pymcp-new isolated-pymcp-feature --type discovered-from
```

### 3. Link Related Work

Use `related` to group similar issues without creating false blocking relationships:

```bash
# Both UI components are independent but related
bd dep add button-component dropdown-component --type related
```

### 4. Avoid Dependency Cycles

Always check for cycles before committing:

```bash
bd dep cycles
# Should report: ✓ No dependency cycles detected
```

### 5. Regular Dependency Review

Periodically review dependencies to ensure they're still valid:

```bash
# List all dependencies
bd list --json | jq -r '.[] | select(.dependency_count > 0)'

# Review dependency tree
bd dep tree <issue-id>
```

## Workflow Integration

### Agent-Based Discovery

For multi-agent workflows (Builder, Observer, Meta-Observer):

```bash
# Builder discovers an issue during implementation
bd create "Refactor authentication module" --status open
bd dep add new-issue current-issue --type discovered-from

# Observer creates architectural recommendation
bd create "Add caching layer" --status open
bd dep add caching-issue feature-issue --type related

# Meta-Observer identifies process improvement
bd create "Update testing guidelines" --status open
bd dep add process-issue current-sprint --type discovered-from
```

### Git Integration

Dependencies sync with git through `bd sync`:

```bash
# After adding dependencies
bd dep add issue-a issue-b --type blocks

# Sync to git
bd sync

# Push to remote
git push
```

### Session Planning

Use dependencies to plan session work:

```bash
# Find what's ready to work on
bd ready

# Check what's blocked
bd blocked

# View full context for an issue
bd show <issue-id> --json | jq '.dependencies, .dependents'
```

## Database Schema

Dependencies are stored in the database with the following structure:

```sql
CREATE TABLE dependencies (
    source_id TEXT NOT NULL,      -- The issue that depends on something
    target_id TEXT NOT NULL,      -- The issue being depended upon
    dependency_type TEXT NOT NULL, -- blocks, related, discovered-from, parent-child
    created_at TIMESTAMP,
    PRIMARY KEY (source_id, target_id)
);
```

**Important**:
- `source_id` depends on `target_id`
- For blocking: `source_id` is blocked by `target_id`
- Direction matters for proper resolution

## Troubleshooting

### Issue Appears Ready But Shows as Blocked

Check the dependency types:

```bash
bd show <issue-id> --json | jq '.dependencies[] | .dependency_type'
```

Only `blocks` type dependencies affect ready/blocked status.

### Cycle Detection False Positives

Cycles are only detected in `blocks` dependencies. `related` and `discovered-from` can form cycles without causing issues.

### Dependencies Not Syncing

Ensure auto-flush is enabled:

```bash
bd config get auto-flush
# Should not be disabled

# Force sync
bd sync
```

## Advanced Usage

### Bulk Dependency Management

```bash
# Add multiple dependencies via script
for dep in issue-1 issue-2 issue-3; do
  bd dep add my-feature $dep --type blocks
done

# Remove all dependencies for an issue
bd show my-issue --json | jq -r '.dependencies[].id' | while read dep; do
  bd dep remove my-issue $dep
done
```

### Dependency Analysis

```bash
# Count blocking dependencies per issue
bd list --json | jq -r '.[] | "\(.id): \(.dependency_count) deps"'

# Find issues with most dependents
bd list --json | jq -r '.[] | "\(.dependent_count): \(.id)"' | sort -rn | head -10

# Find orphaned issues (no deps, no dependents)
bd list --json | jq -r '.[] | select(.dependency_count == 0 and .dependent_count == 0) | .id'
```

## See Also

- [Beads Documentation](https://github.com/steveyegge/beads)
- [Multi-Agent Workflow Framework](../AGENTS.md)
- [Session Management](../README.md)
