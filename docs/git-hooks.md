# Git Hooks Configuration for BD Auto-Sync

This document describes the Git hooks setup for automatic synchronization of BD (beads) issue tracking data with Git.

## Overview

The BD system uses Git hooks to ensure that the SQLite database and JSONL export files stay synchronized with Git operations. This prevents race conditions and ensures all team members have consistent issue data.

## Installed Hooks

All hooks are installed using the "thin shim" pattern (v1), which delegates to `bd hooks run <hook-name>`. This ensures hook behavior stays in sync with the installed BD version without manual updates.

### pre-commit

**Purpose**: Flushes pending BD changes to `.beads/issues.jsonl` before creating a commit.

**Behavior**:
- Checks if `bd` command is available
- Detects if the repository is a BD workspace
- Handles both regular repositories and Git worktrees
- Runs `bd sync --flush-only` to export database changes to JSONL
- Automatically stages the JSONL file if modified (regular repos only)
- Exits with error if flush fails

**Why it's needed**: Prevents the race condition where daemon auto-flush fires after the commit is created, leaving the JSONL file out of sync with the Git history.

### post-merge

**Purpose**: Imports updated issues from `.beads/issues.jsonl` after a `git pull` or merge.

**Behavior**:
- Checks if `bd` command is available
- Detects if the repository is a BD workspace
- Handles both regular repositories and Git worktrees
- Runs `bd import -i .beads/issues.jsonl` to import changes
- Issues a warning if import fails (doesn't block the merge)

**Why it's needed**: Ensures the local database is updated with changes from remote after pulling or merging.

### pre-push

**Purpose**: Prevents pushing stale JSONL files to remote.

**Behavior**:
- Validates that the JSONL export is up-to-date with the database
- Blocks the push if there are unflushed changes
- Ensures team members don't receive incomplete or stale issue data

**Why it's needed**: Maintains data integrity across the team by ensuring all pushed commits include the latest JSONL exports.

### post-checkout

**Purpose**: Imports JSONL after switching branches.

**Behavior**:
- Runs after `git checkout` operations
- Imports the JSONL file from the newly checked-out branch
- Ensures the database reflects the branch's issue state
- Runs silently to avoid cluttering checkout output

**Why it's needed**: Keeps the database synchronized when switching between branches with different issue states.

## Auto-Flush and Auto-Import Configuration

The BD system is configured with automatic synchronization features:

### Auto-Flush (Enabled)

- **Configuration**: `no-auto-flush: false` in `.beads/config.yaml`
- **Debounce**: 5 seconds (configured via `flush-debounce: "5s"`)
- **Behavior**: After any CRUD operation (create, update, delete), the daemon waits 5 seconds for additional operations, then automatically exports the database to JSONL
- **Purpose**: Reduces file system writes by batching operations while keeping the export reasonably up-to-date

### Auto-Import (Enabled)

- **Configuration**: `no-auto-import: false` in `.beads/config.yaml`
- **Behavior**: When BD reads from the database, it first checks if the JSONL file is newer than the last import timestamp. If so, it automatically imports the JSONL before proceeding
- **Purpose**: Ensures the database always reflects the latest JSONL state, especially after Git operations

## Merge Driver Configuration

The repository uses a custom merge driver for JSONL files to handle concurrent edits:

### Git Configuration

```bash
# Merge driver command
git config merge.beads.driver "bd merge %A %O %A %B"

# Merge driver description
git config merge.beads.name "bd JSONL merge driver"
```

### .gitattributes

```
.beads/issues.jsonl merge=beads
```

**How it works**:
- When Git detects a merge conflict in `.beads/issues.jsonl`, it invokes `bd merge`
- BD performs a semantic merge of JSONL records rather than line-based merge
- Issues are merged by ID, with conflict resolution rules applied
- This prevents most merge conflicts in issue tracking data

## Installation and Verification

### Installing Hooks

```bash
# Install all BD hooks
bd hooks install

# Verify installation
bd hooks list
```

Expected output:
```
Git hooks status:
  ✓ pre-commit: installed (shim v1)
  ✓ post-merge: installed (shim v1)
  ✓ pre-push: installed (shim v1)
  ✓ post-checkout: installed (shim v1)
```

### Verifying Configuration

```bash
# Check overall BD health
bd doctor

# Verify auto-flush setting
bd config get flush.debounce
# Expected: 5s

# Check merge driver
git config --get merge.beads.driver
# Expected: bd merge %A %O %A %B
```

## Worktree Considerations

Git worktrees share the `.git` directory but have separate working trees. The hooks handle this by:

1. Detecting when running in a worktree vs. regular repository
2. Locating `.beads/` in the main repository root for worktrees
3. Skipping `git add` operations for JSONL files in worktrees (files are outside the worktree)

**Important**: Each worktree shares the same `.beads/` directory from the main repository. Changes in one worktree affect all others.

## Troubleshooting

### Hook Not Running

If a hook doesn't execute:

1. Verify `bd` is in your PATH: `which bd`
2. Check hook permissions: `ls -l .git/hooks/`
3. Verify installation: `bd hooks list`
4. Check daemon status: `bd doctor`

### Import/Export Failures

If auto-import or auto-flush fails:

1. Check daemon logs: `cat .beads/daemon.log`
2. Manually test export: `bd sync --flush-only`
3. Manually test import: `bd import -i .beads/issues.jsonl`
4. Check file permissions: `ls -l .beads/`

### Merge Conflicts

If merge conflicts occur in JSONL files:

1. Verify merge driver is configured: `git config --get merge.beads.driver`
2. Check `.gitattributes` includes the merge directive
3. Try manual merge: `bd merge <current> <base> <other>`

### Debounce Not Working

If changes flush immediately instead of after 5 seconds:

1. Verify configuration: `cat .beads/config.yaml | grep flush-debounce`
2. Check daemon is using config: `bd doctor`
3. Restart daemon: `bd daemon stop && bd daemon start`

## References

- [BD Hooks Documentation](https://github.com/steveyegge/beads/tree/main/examples/git-hooks)
- [BD Configuration Reference](https://github.com/steveyegge/beads/blob/main/docs/config.md)
- [Git Hooks Overview](https://git-scm.com/docs/githooks)
- [Git Worktrees](https://git-scm.com/docs/git-worktree)

## Version Information

- BD Version: 0.32.1
- Hook Shim Version: v1
- Configuration Format: YAML
- JSONL Export File: `.beads/issues.jsonl`
- Database File: `.beads/beads.db`
