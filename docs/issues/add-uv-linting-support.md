# Add UV for improved Python dependency management and linting support

## Description

We need to update the project to use UV (the faster Rust-based Python package manager) for managing dependencies and running linting tools. This will improve performance and provide a consistent interface for code quality checks.

## Tasks

- [x] Add `make lint`, `make format`, and `make typecheck` commands that use UV
- [x] Update the Dockerfile to install and use UV for package management
- [x] Update CLAUDE.md with instructions for the new commands
- [x] Create Claude command `/user:lint` for easy linting from Claude Code
- [x] Document the changes in README and other relevant places

## Implementation notes

- UV 0.6.4 is available in the system
- Python 3.11 is the default Python version
- All linting tools should be installed via UV
- The Makefile should be updated to provide a consistent interface

## Related

- Dockerfile changes
- Makefile updates
- CLAUDE.md documentation