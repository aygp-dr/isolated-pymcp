# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Build container**: `make build` - Creates Docker/Podman image
- **Run environment**: `make run` - Starts container with mounted volumes
- **Install MCP servers**: `./scripts/install-mcp-servers.sh` - Installs MCP components
- **Run all tests**: `python -m pytest tests/` - Run all Python tests
- **Single test**: `python -m pytest tests/test_file.py::test_name -v` - Run specific test
- **Parametrized test**: `python -m pytest tests/test_file.py::test_name[param]` - Run test with parameter
- **Skip slow tests**: `python -m pytest -m "not slow"` - Skip tests marked as slow

## Code Quality Commands
- **Lint code (Make)**: `make lint` - Run flake8 linting via uv
- **Format code (Make)**: `make format` - Format Python code with Black via uv
- **Type check (Make)**: `make typecheck` - Run type checking with mypy via uv
- **Run all checks**: `make check-all` - Run all lint, format, and type checks
- **Format code (direct)**: `black algorithms/ tests/` - Format Python code with Black
- **Type check (direct)**: `mypy algorithms/ tests/` - Run type checking with mypy
- **Lint code (direct)**: `flake8 algorithms/ tests/` - Run linting with flake8

## Code Style Guidelines
- **Python**: PEP 8 with Black (100 char line length), type annotations required
- **Docstrings**: Google style with Args/Returns sections and complexity analysis
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types, proper error propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for scripts
- **Testing**: Use pytest with parametrized tests, markers for slow/benchmark tests
- **Performance**: Include Big O complexity analysis in docstrings
- **Container compatibility**: Use `DOCKER_CMD=$(command -v podman || command -v docker)`

## MCP Commands
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP
- **Direct Claude analysis**: `make claude-analyze ALGO=algorithm_name` - Local Claude analysis