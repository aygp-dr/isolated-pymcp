# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Build container**: `make build` - Creates Docker/Podman image
- **Run environment**: `make run` - Starts container with mounted volumes
- **Install MCP servers**: `./scripts/install-mcp-servers.sh` - Installs MCP server components
- **Check MCP setup**: `./scripts/check-mcp-setup.sh` - Verifies MCP CLI installation
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP
- **Direct Claude analysis**: `make claude-analyze ALGO=algorithm_name` - Local Claude analysis
- **Run all tests**: `python -m pytest tests/` - Run all Python tests
- **Single test**: `python -m pytest tests/test_file.py::test_name -v` - Run specific test
- **Stop environment**: `make stop` - Stops and removes container
- **Format code**: `black algorithms/ tests/` - Format Python code with Black
- **Type check**: `mypy algorithms/ tests/` - Run type checking with mypy
- **Lint code**: `flake8 algorithms/ tests/` - Run linting with flake8

## Code Style Guidelines
- **Python**: PEP 8 with Black (100 char line length), type annotations required
- **Docstrings**: Google style with Args/Returns sections and complexity analysis
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types, proper error propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for scripts
- **Testing**: pytest with parametrized tests, markers for slow/benchmark tests (`@pytest.mark.slow`, `@pytest.mark.benchmark`)
- **Shebang lines**: Use `#!/usr/bin/env python3` for compatibility
- **Security**: No hardcoded credentials, use environment variables

## Git Standards

### Commit Standards
- Follow Conventional Commits: `<type>[scope]: <description>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`
- Use Git trailers instead of Co-authored-by in message body
- Example: `git commit -m "feat(mcp): add python-lsp support" --trailer "Co-authored-by: Name <email>"`

### Branch Naming Standards
- Format: `<type>/<issue-number>-<short-description>`
- Types: Same as commit types (`feat`, `fix`, `docs`, etc.)
- Issue number: GitHub issue number (e.g., `33`)
- Description: Brief kebab-case description
- Examples:
  - `feat/33-claude-md-algo-guidance`
  - `security/21-container-resource-limits`
  - `fix/18-curl-bash-pattern`

## FreeBSD Compatibility
- Design for cross-platform compatibility
- Use command detection: `DOCKER_CMD=$(command -v podman || command -v docker)`
- Avoid Linux-specific path assumptions