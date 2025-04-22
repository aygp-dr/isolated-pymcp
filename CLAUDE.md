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

## Python Commands (using UV with Python 3.11)
- **Install deps**: `make install-dev` - Install dependencies with UV
- **Run all tests**: `make pytest` - Run all Python tests
- **Single test**: `make PYTEST_ARGS="tests/test_factorial.py::test_factorial_recursive -v"` - Run specific test
- **Test class**: `make PYTEST_ARGS="tests/test_factorial.py::TestClass -v"` - Run specific test class
- **Skip slow tests**: `make PYTEST_ARGS="-m 'not slow'"` - Skip tests marked as slow
- **Run all linters**: `make lint` - Run all linters (isort, black, mypy, flake8)
- **Format code**: `make black` - Format Python code with Black (100 char line)
- **Type check**: `make mypy` - Run type checking with mypy

## Code Style Guidelines
- **Python**: PEP 8 with Black (100 char line length), type annotations required
- **Docstrings**: Google style with Args/Returns sections and complexity analysis (time & space)
- **Imports**: Group (stdlib → third-party → local) with blank line separation
- **Error handling**: Use specific exception types, proper error propagation
- **Naming**: snake_case for variables/functions, PascalCase for classes, kebab-case for shell scripts
- **Testing**: pytest with parametrized tests, markers for slow/benchmark tests
- **Shebang lines**: `#!/usr/bin/env python3` for compatibility
- **Security**: No hardcoded credentials, use environment variables

## Git Commit Standards
- Follow Conventional Commits: `<type>[scope]: <description>`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `build`, `ci`
- Use Git trailers instead of Co-authored-by in message body

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

## Claude Code Commands
- **Algorithm comparison**: `/compare algorithms/factorial.py algorithms/fibonacci.py`
- **Complexity analysis**: `/complexity-analysis algorithms/primes.py`
- **Implementation suggestions**: `/suggest-optimizations algorithms/fibonacci.py`
- **Adding new algorithm**: `/implement <algorithm_name> -t [time complexity] -s [space complexity]`
- **Test generation**: `/generate-tests algorithms/primes.py`
- **Benchmark execution**: `/benchmark algorithms/factorial.py` (runs benchmark and analyzes results)