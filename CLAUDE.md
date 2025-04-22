# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands
- **Build container**: `make build` - Creates Docker/Podman image
- **Run environment**: `make run` - Starts container with mounted volumes
- **Install MCP servers**: `./scripts/install-mcp-servers.sh` - Installs MCP server components 
- **Check MCP setup**: `./scripts/check-mcp-setup.sh` - Verifies MCP CLI installation
- **Test MCP servers**: `make test` - Verifies all MCP servers are working
- **Run Python example**: `python scripts/mcp_simple_example.py` - Tests MCP Python runner
- **Quick Python**: `./scripts/run_python_code <code>` - Run Python code directly
- **Analyze algorithm**: `make analyze ALGO=algorithm_name` - Run analysis via MCP
- **Review PR**: `make review-pr PR=123 [ROLE=engineer|manager|sre|director]` - Review PR with role-based checks
- **Parametrized test**: `python -m pytest tests/test_file.py::test_name[param]` - Run test with parameter

## Python Commands (using UV with Python 3.11)
- **Install deps**: `make install-dev` - Install dependencies with UV
- **Run all tests**: `make pytest` - Run all Python tests
- **Single test**: `make PYTEST_ARGS="tests/test_factorial.py::test_factorial_recursive -v"` - Run specific test
- **Test class**: `make PYTEST_ARGS="tests/test_factorial.py::TestClass -v"` - Run specific test class
- **Skip slow tests**: `make PYTEST_ARGS="-m 'not slow'"` - Skip tests marked as slow
- **Run all linters**: `make lint` - Run all linters (isort, black, mypy, flake8)
- **Format code**: `make black` - Format Python code with Black (100 char line)
- **Type check**: `make mypy` - Run type checking with mypy

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
- **Docstrings**: Google style with Args/Returns sections and complexity analysis (time & space)
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types, proper error propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for shell scripts
- **Testing**: pytest with parametrized tests, markers for slow/benchmark tests
- **Shebang lines**: `#!/usr/bin/env python3` for compatibility
- **Security**: No hardcoded credentials, use environment variables
- **Performance**: Include Big O complexity analysis in docstrings
- **Container compatibility**: Use `DOCKER_CMD=$(command -v podman || command -v docker)`

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

## Project Organization
- **algorithms/**: Core algorithm implementations
- **tests/**: Test files matching test_*.py pattern
- **scripts/**: Utility scripts for setup and execution
- **config/**: Configuration files for MCP and services

## Algorithm Guidelines
- **Time/Space Complexity**: Always include Big O notation in docstrings
- **Multiple Implementations**: Provide various approaches (recursive, iterative, etc.)
- **Benchmarking**: Include benchmark functions for performance comparison
- **Documentation**: Add detailed explanation of algorithm logic and tradeoffs
- **Types**: Use proper type annotations for all function parameters and returns
- **Testing**: Create parametrized tests with known input/output values
- **Primary Algorithms**:
  - **Factorial**: Recursive, tail-recursive, memoized, iterative implementations
  - **Fibonacci**: Recursive, memoized, iterative, generator implementations
  - **Primes**: Naive testing, optimized testing, sieve algorithms

## MCP Algorithm Analysis
- **Run analysis**: `make analyze ALGO=algorithm_name` (e.g., `make analyze ALGO=fibonacci`)
- **Analysis pipeline**:
  1. LSP analysis via multilspy server to check code quality
  2. Code execution via python-runner MCP server
  3. Claude Code analysis of algorithm implementation
- **Analysis questions**:
  - Algorithmic complexity assessment
  - Bug and inefficiency detection
  - Implementation improvement suggestions
  - Trade-offs between different approaches
  - Unique implementation characteristics
- **Output location**: Analysis results stored in `analysis_results/` directory

## Claude Code Slash Commands
- **/user:mise-en-place** - Organize workspace and ensure everything is in a clean state
- **/user:security-review** - Perform a thorough security review of the codebase
- **/user:lint-code** - Run comprehensive code quality checks
- **/user:lint-fix** - Fix linting issues automatically
- **/user:generate-docs** - Create or update project documentation
- **/user:issue-triage** - Triage and manage GitHub issues
- **Algorithm commands**:
  - **/compare algorithms/factorial.py algorithms/fibonacci.py**
  - **/complexity-analysis algorithms/primes.py**
  - **/suggest-optimizations algorithms/fibonacci.py**
  - **/implement <algorithm_name> -t [time complexity] -s [space complexity]**
  - **/generate-tests algorithms/primes.py**
  - **/benchmark algorithms/factorial.py**

For a complete list of available commands, see `.claude/README.md`.
