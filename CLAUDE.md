# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Run container**: `make run` - Starts container with mounted volumes
- **Stop container**: `make stop` - Stop and remove the container
- **Build image**: `make build` - Build the Docker/Podman image
- **Clean up**: `make clean` - Remove container and image
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Run all tests**: `make pytest` - Run all Python tests
- **Test with verbose**: `make pytest-verbose` - Run tests with verbose output
- **Single test**: `python -m pytest tests/test_file.py::test_name -v` - Run specific test
- **Lint code**: `make lint` - Run flake8 linter on Python code
- **Format code**: `make format` - Format Python code with Black
- **Sort imports**: `make isort` - Sort imports with isort
- **Type check**: `make typecheck` - Run mypy type checking
- **Run all checks**: `make check-all` - Run all checks (lint, format, typecheck)
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP
- **Claude analyze**: `make claude-analyze ALGO=algorithm_name` - Run algorithm analysis with local Claude Code

## Setup & Environment Commands
- **Create directories**: `make dirs` - Create required directories
- **Check secrets**: `make check-secrets` - Check for required secrets and set up .env file
- **Install dev tools**: `make install-dev-tools` - Install development tools (flake8, black, mypy)
- **Install dev deps**: `make install-dev` - Install development dependencies with UV
- **Install MCP CLI**: `make install-mcp` - Install MCP CLI with UV
- **Create venv**: `make ensure-venv` - Create Python virtual environment with uv

## MCP Server Commands
- **List MCP tools**: `make mcp-tools` - List MCP tools with prettier formatting
- **Test all servers**: `make test-all-mcp-servers` - Test all MCP servers with the tools list request
- **Run MCP warmup**: `make mcp-warmup` - Warm up the Pyodide environment
- **Start Pydantic MCP**: `make pydantic-mcp-start` - Start Pydantic MCP run-python server
- **Test Pydantic MCP**: `make pydantic-mcp-test` - Test Pydantic MCP run-python server
- **Stop Pydantic MCP**: `make pydantic-mcp-stop` - Stop Pydantic MCP run-python server

## Beads Dependency Commands
- **Show dependency stats**: `make dep-stats` - Display comprehensive dependency statistics
- **Validate dependencies**: `make dep-validate` - Check for cycles, dangling refs, and other issues
- **Full analysis**: `make dep-analysis` - Run stats and validation together
- **Check cycles**: `bd dep cycles` - Detect circular dependencies
- **Show blocked**: `bd blocked` - List all blocked issues
- **Add dependency**: `bd dep add <issue> <depends-on> [--type TYPE]` - Add a dependency (blocks, related, discovered-from, parent-child)
- **Show dep tree**: `bd dep tree <issue>` - Show full dependency tree for an issue

## Git Worktree Commands
- **Create worktree**: `make worktree-new NAME=feature-name [ISSUE=42] [INIT=1]` - Create a new git worktree
- **List worktrees**: `make worktree-list` - List all git worktrees
- **Worktree status**: `make worktree-status` - Show status of all git worktrees
- **Delete worktree**: `make worktree-delete NAME=feature-name [BRANCH=1]` - Delete a git worktree
- **Switch worktree**: `make worktree-switch NAME=feature-name` - Show how to switch to a worktree
- **Init worktree**: `make worktree-init [NAME=feature-name]` - Initialize worktree environment(s)

## Org Mode Commands
- **Tangle configs**: `make tangle` - Generate config files from org files
- **Detangle configs**: `make detangle` - Update org files from modified configs
- **Generate README.md**: `make README.md` - Generate Markdown from README.org for PyPi and uv

## Example & Utility Commands
- **Simple addition**: `make add` - Simple addition example using MCP run-python
- **Run Fibonacci**: `make run-fibonacci` - Run Fibonacci algorithm via MCP server
- **Run primes**: `make run-primes` - Run primes algorithm via MCP server
- **Run any payload**: `make run-payload PAYLOAD=filename.json` - Run any payload from tests/payloads/
- **Run Python hello**: `make run-python-hello` - Run simple Python hello world via tools/call
- **Run factorial**: `make run-python-factorial` - Run factorial algorithm via tools/call

## Code Style Guidelines
- **Python**: PEP 8 with Black (100 char line length), type annotations required
- **Docstrings**: Google style with Args/Returns sections and complexity analysis
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types with proper propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for scripts
- **Testing**: Use pytest with parametrized tests (`@pytest.mark.parametrize`)
- **Security**: No hardcoded credentials, use environment variables instead

## Development Process
- Before committing: `make lint`, `make typecheck`, `make test`
- Design for cross-platform compatibility (Linux and FreeBSD)
- Follow conventional commits format: `<type>[scope]: <description>`
- Git branches: `<type>/<issue-number>-<short-description>` (e.g., `feat/33-feature-name`)
- **CLI Tool**: Use gh cli tool by default
- Use `--trailer` during commits
- Use conventional commits
- Don't use "generated with" in the body of commit messages

## Project Organization
- **algorithms/**: Core algorithm implementations with multiple approaches (recursive, iterative)
- **tests/**: Test files matching test_*.py pattern with parametrized tests
- **scripts/**: Utility scripts for setup and execution
- **config/**: Configuration files for MCP and services
- **docs/**: Project documentation including status reports

## Algorithm Guidelines
- Always include Big O notation and docstrings with Google style
- Provide multiple implementations (recursive, iterative, etc.) with benchmarking
- Use proper type annotations and create parametrized tests