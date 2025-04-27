# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Run container**: `make run` - Starts container with mounted volumes
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Run all tests**: `make pytest` - Run all Python tests
- **Single test**: `python -m pytest tests/test_file.py::test_name -v` - Run specific test
- **Lint code**: `make lint` - Run flake8 linter on Python code
- **Format code**: `make format` - Format Python code with Black
- **Type check**: `make typecheck` - Run mypy type checking
- **Run all checks**: `make check-all` - Run all checks (lint, format, typecheck)
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP

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