# Test Plan for README.md Management

## Goal
Ensure README.md is available for Python package management tools (UV, pip) while keeping it out of Git tracking.

## Current State
- README.md is currently maintained in Git
- It's generated from README.org using emacs/org-mode
- Several make targets depend on README.md: `test`, `pytest`, `pytest-verbose`

## Required Changes
1. Remove README.md from Git tracking
2. Ensure README.md is in .gitignore (already there)
3. Verify README.md can still be generated via `gmake README.md`
4. Ensure dependant make targets work correctly

## Test Scenarios

### Scenario 1: Removing README.md from Git
```bash
# Remove README.md from git tracking without deleting the file
git rm --cached README.md
git commit -m "chore: stop tracking README.md in Git"
```

**Expected Result**: README.md remains in the filesystem but no longer appears in git status.

### Scenario 2: Generating README.md
```bash
# Remove the local README.md
rm README.md
# Generate it using make
gmake README.md
```

**Expected Result**: README.md is generated successfully from README.org.

### Scenario 3: Test Dependencies
```bash
# Test 'make test' target
make test
# Test 'make pytest' target
make pytest
# Test 'make pytest-verbose' target
make pytest-verbose
```

**Expected Result**: All targets should work, automatically generating README.md if needed.

### Scenario 4: Python Environment Setup

```bash
# Ensure venv setup works
rm -rf .venv
make .venv
# Test activate target
make activate
```

**Expected Result**: Virtual environment is created and activated successfully.

### Scenario 5: Installation (simulated)

```bash
# Delete README.md
rm README.md
# Run UV installation (with -n for dry run)
uv pip install -e . -n
```

**Expected Result**: Installation process should generate README.md before proceeding.

## Verification Points
- README.md is not tracked in git
- README.md is listed in .gitignore (already confirmed)
- README.md is generated on-demand by make targets
- Python packaging tools can access README.md for package metadata

## Implementation Plan
1. Remove README.md from Git tracking
2. Modify make targets that depend on README.md to ensure it's always generated first
3. Create a small helper script to generate README.md for CI/CD environments if needed
4. Update documentation to reflect that README.md is generated, not tracked