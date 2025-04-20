# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Build container**: `make build` - Creates the Docker/Podman image
- **Run environment**: `make run` - Starts container with mounted volumes
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP
- **Direct Claude analysis**: `make claude-analyze ALGO=algorithm_name` - Local Claude analysis
- **Run single Python test**: `python -m pytest tests/test_file.py::test_name -v`
- **Stop environment**: `make stop` - Stops and removes container

## Code Style Guidelines
- **Python**: PEP 8 with type annotations, docstrings for all functions
- **Shebang lines**: Use `#!/usr/bin/env [interpreter]` for compatibility
- **Imports**: Group imports (stdlib → third-party → local) with blank lines
- **Error handling**: Use explicit exception types, command detection for tools
- **Naming**: kebab-case for scripts (e.g., `mcp-python-test.sh`)
- **Security**: No hardcoded credentials, use environment variables
- **Docker/Podman**: Support both runtimes, explicit port mappings, named containers

## Git Commit Standards
- Follow Conventional Commits: `<type>[scope]: <description>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`
- Use Git trailers instead of Co-authored-by in message body
- Example: `git commit -m "feat(mcp): add python-lsp support" --trailer "Co-authored-by: Name <email>"`

## FreeBSD Compatibility
- Design for cross-platform compatibility
- Use command detection: `DOCKER_CMD=$(command -v podman || command -v docker)`
- Avoid Linux-specific path assumptions