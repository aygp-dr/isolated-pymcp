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
- **docs/**: Project documentation and status reports

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