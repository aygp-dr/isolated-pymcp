# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Build container**: `make build` - Builds Docker/Podman image
- **Run environment**: `make run` - Starts container with mounted volumes
- **Install MCP servers**: `./scripts/install-mcp-servers.sh` - Installs MCP server components 
- **Check MCP setup**: `./scripts/check-mcp-setup.sh` - Verifies MCP CLI installation
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Run all tests**: `python -m pytest tests/` - Run all Python tests
- **Single test**: `python -m pytest tests/test_file.py::test_name -v` - Run specific test
- **Format code**: `black algorithms/ tests/` - Format code with Black
- **Type check**: `mypy algorithms/ tests/` - Run type checking
- **Lint code**: `flake8 algorithms/ tests/` - Run linting
- **MCP tools**: `make list-mcp-tools` - List available MCP tools
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run MCP analysis

## Code Style Guidelines
- **Python**: PEP 8 with Black (100 char line length), type annotations required
- **Docstrings**: Google style with Args/Returns sections and complexity analysis
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types with proper propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for scripts
- **Testing**: Use pytest with parametrized tests and performance markers (`@pytest.mark.slow`, `@pytest.mark.benchmark`)
- **Shebang**: Use `#!/usr/bin/env python3` for cross-platform compatibility
- **Security**: No hardcoded credentials, use environment variables instead

## FreeBSD Compatibility
- Design for cross-platform compatibility (works on Linux and FreeBSD)
- Use command detection: `DOCKER_CMD=$(command -v podman || command -v docker)`
- Follow conventional commits format: `<type>[scope]: <description>`
