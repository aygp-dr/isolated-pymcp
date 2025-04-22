# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

### Container Management
- **Build container**: `make build` - Builds Docker/Podman image
- **Run environment**: `make run` - Starts container with mounted volumes
- **Stop container**: `make stop` - Stops and removes the container
- **Clean environment**: `make clean` - Removes container and image
- **Create directories**: `make dirs` - Creates required project directories

### MCP and Analysis
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP
- **Direct analysis**: `make claude-analyze ALGO=algorithm_name` - Analyze code locally with Claude
- **MCP tools**: `make mcp-tools` - Lists available MCP tools
- **MCP resources**: `make list-mcp-resources` - Lists available MCP resources
- **MCP prompts**: `make list-mcp-prompts` - Lists available MCP prompts
- **Test all servers**: `make test-all-mcp-servers` - Tests all MCP servers

### Python Development
- **Run all tests**: `make pytest` - Run all Python tests
- **Run verbose tests**: `make pytest-verbose` - Run tests with verbose output
- **Single test**: `python -m pytest tests/test_file.py::test_name -v` - Run specific test
- **Format code**: `make format` - Format Python code with Black
- **Sort imports**: `make isort` - Sort imports with isort
- **Lint code**: `make lint` - Run flake8 linter on Python code
- **Type check**: `make typecheck` - Run mypy type checking
- **Run all checks**: `make check-all` - Run all checks (lint, format, typecheck)
- **Install tools**: `make install-dev-tools` - Install development tools (flake8, black, mypy)

### Org Mode
- **Tangle**: `make tangle` - Generate config files from org files
- **Detangle**: `make detangle` - Update org files from modified configs
- **Generate README**: `make README.md` - Generate Markdown version of README.org

## Code Style Guidelines
- **Python**: PEP 8 with Black (100 char line length), type annotations required
- **Docstrings**: Google style with Args/Returns sections and complexity analysis
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types with proper propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for scripts
- **Testing**: Use pytest with parametrized tests and performance markers (`@pytest.mark.slow`, `@pytest.mark.benchmark`)
- **Shebang**: Use `#!/usr/bin/env python3` for cross-platform compatibility
- **Security**: No hardcoded credentials, use environment variables instead

## Script Reference

### Setup Scripts
- **Environment setup**: `./scripts/setup.sh` - Initial environment setup
- **Install MCP**: `./scripts/install-mcp-servers.sh` - Install MCP server components
- **Check MCP**: `./scripts/check-mcp-setup.sh` - Verify MCP CLI installation
- **Start servers**: `./scripts/start-mcp-servers.sh` - Start all MCP servers
- **Update servers**: `./scripts/update-mcp-servers.sh` - Update MCP servers to latest versions
- **Tangle config**: `./scripts/tangle-setup.sh` - Generate configuration files from org source
- **Cleanup**: `./scripts/cleanup.sh` - Clean project artifacts and temporary files

### Analysis Scripts
- **Algorithm analysis**: `./scripts/analyze-with-claude.sh <algorithm>` - Analyze an algorithm using Claude
- **MCP Python test**: `./scripts/mcp-python-test.sh` - Test MCP Python servers
- **Benchmark**: `./scripts/benchmark.sh` - Run performance benchmarks
- **PR review**: `./scripts/review-pr.sh <PR> [ROLE]` - Review a GitHub pull request
- **Run Python**: `./scripts/run_python_code <code>` - Run Python code through MCP runner

## Development Process Guidelines
- Before committing changes, always run:
  1. `gmake help` - Verify all targets are documented
  2. `gmake lint` - Ensure code passes style checks
  3. `gmake test` - Verify functionality works
- Never add undocumented make targets - all targets must have ## descriptions
- Make tests should pass on both Linux and FreeBSD environments

## FreeBSD Compatibility
- Design for cross-platform compatibility (works on Linux and FreeBSD)
- Use command detection: `DOCKER_CMD=$(command -v podman || command -v docker)`
- Follow conventional commits format: `<type>[scope]: <description>`
