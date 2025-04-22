# Makefile for isolated-pymcp
# Author: Aidan Pace (apace@defrecord.com)

# Include environment variables if .envrc exists
-include .envrc

# Default variables if not set in .envrc
CONTAINER_NAME ?= isolated-pymcp
IMAGE_NAME ?= isolated-pymcp
MCP_RUNPYTHON_PORT ?= 3001
MCP_MEMORY_PORT ?= 3002
MCP_FILESYSTEM_PORT ?= 3003
MCP_GITHUB_PORT ?= 3004
MCP_MULTILSPY_PORT ?= 3005
MCP_PYTHONLSP_PORT ?= 3006

# FreeBSD compatibility
DOCKER_CMD := $(shell command -v podman || command -v docker)

# Use UV for Python commands
PYTHON := uv run --python=3.11

# Default target
.PHONY: help
help:
	@echo "isolated-pymcp Makefile"
	@echo "---------------------"
	@echo "Docker & Container:"
	@echo "  make build          - Build the Docker image"
	@echo "  make run            - Run the container"
	@echo "  make stop           - Stop the container"
	@echo "  make clean          - Remove containers and images"
	@echo ""
	@echo "MCP & Analysis:"
	@echo "  make test           - Test MCP servers"
	@echo "  make analyze ALGO=x - Analyze algorithm x"
	@echo "  make claude-analyze ALGO=x - Local Claude analysis"
	@echo "  make install-mcp    - Install MCP CLI with UV"
	@echo ""
	@echo "Python Development (using UV with Python 3.11):"
	@echo "  make pytest          - Run pytest"
	@echo "  make pytest-verbose  - Run pytest in verbose mode"
	@echo "  make lint           - Run all linters (isort, black, mypy, flake8)"
	@echo "  make black          - Format code with black"
	@echo "  make isort          - Sort imports"
	@echo "  make mypy           - Type checking"
	@echo "  make flake8         - Style enforcement"
	@echo "  make install-dev    - Install development dependencies with UV"
	@echo ""
	@echo "Org Mode:"
	@echo "  make tangle         - Generate config files from org sources"
	@echo "  make detangle       - Update org files from modified configs"
	@echo "  make help           - Show this help"

# Build the Docker image
.PHONY: build
build:
	@echo "Building $(IMAGE_NAME) image..."
	$(DOCKER_CMD) build -t $(IMAGE_NAME) .

# Run the container
.PHONY: run
run:
	@echo "Running $(CONTAINER_NAME) container..."
	$(DOCKER_CMD) run -d --name $(CONTAINER_NAME) \
		-e GITHUB_TOKEN="$(GITHUB_TOKEN)" \
		-e ANTHROPIC_API_KEY="$(ANTHROPIC_API_KEY)" \
		-p $(MCP_RUNPYTHON_PORT):$(MCP_RUNPYTHON_PORT) \
		-p $(MCP_MEMORY_PORT):$(MCP_MEMORY_PORT) \
		-p $(MCP_FILESYSTEM_PORT):$(MCP_FILESYSTEM_PORT) \
		-p $(MCP_GITHUB_PORT):$(MCP_GITHUB_PORT) \
		-p $(MCP_MULTILSPY_PORT):$(MCP_MULTILSPY_PORT) \
		-p $(MCP_PYTHONLSP_PORT):$(MCP_PYTHONLSP_PORT) \
		-v $(PWD)/algorithms:/home/mcp/algorithms \
		-v $(PWD)/analysis_results:/home/mcp/analysis_results \
		$(IMAGE_NAME)

# Stop the container
.PHONY: stop
stop:
	@echo "Stopping $(CONTAINER_NAME) container..."
	$(DOCKER_CMD) stop $(CONTAINER_NAME) || true
	$(DOCKER_CMD) rm $(CONTAINER_NAME) || true

# Test MCP servers
.PHONY: test
test:
	@echo "Testing MCP servers..."
	$(DOCKER_CMD) exec $(CONTAINER_NAME) /home/mcp/scripts/mcp-python-test.sh

# Analyze algorithm
.PHONY: analyze
analyze:
	@if [ -z "$(ALGO)" ]; then \
		echo "Error: ALGO not specified"; \
		echo "Usage: make analyze ALGO=fibonacci"; \
		exit 1; \
	fi
	@echo "Analyzing $(ALGO)..."
	$(DOCKER_CMD) exec $(CONTAINER_NAME) /home/mcp/scripts/analyze-with-claude.sh $(ALGO)

# Analyze with Claude directly
.PHONY: claude-analyze
claude-analyze:
	@if [ -z "$(ALGO)" ]; then \
		echo "Error: ALGO not specified"; \
		echo "Usage: make claude-analyze ALGO=fibonacci"; \
		exit 1; \
	fi
	@echo "Analyzing $(ALGO) with Claude Code..."
	claude-code analyze --code "$$(cat algorithms/$(ALGO).py)" --output analysis_results/$(ALGO)_claude.md

# Clean up
.PHONY: clean
clean: stop
	@echo "Removing $(IMAGE_NAME) image..."
	$(DOCKER_CMD) rmi $(IMAGE_NAME) || true
	@echo "Cleanup complete"

# Generate directories
.PHONY: dirs
dirs:
	@mkdir -p algorithms
	@mkdir -p scripts
	@mkdir -p analysis_results
	@mkdir -p emacs
	@mkdir -p data/{memory,filesystem,github}
	@mkdir -p .claude
	@mkdir -p .vscode

# Tangle org files to generate config files
.PHONY: tangle
tangle:
	@echo "Tangling org files to generate config files..."
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "env-setup.org")'
	@echo "Tangling complete. Config files generated."

# Detangle - update org files from modified configs
.PHONY: detangle
detangle:
	@echo "Detangling configs back into org files..."
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle ".dir-locals.el")'
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle "emacs/mcp-helpers.el")'
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle ".claude/preferences.json")'
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle ".vscode/settings.json")'
	@echo "Detangling complete. Org files updated."

# Python testing and development targets
.PHONY: pytest
pytest:
	@echo "Running pytest..."
	$(PYTHON) -m pytest tests/ $(PYTEST_ARGS)

.PHONY: pytest-verbose
pytest-verbose:
	@echo "Running pytest in verbose mode..."
	$(PYTHON) -m pytest tests/ -v $(PYTEST_ARGS)

.PHONY: black
black:
	@echo "Running black formatter..."
	$(PYTHON) -m black algorithms/ tests/

.PHONY: mypy
mypy:
	@echo "Running mypy type checking..."
	$(PYTHON) -m mypy algorithms/ tests/

.PHONY: flake8
flake8:
	@echo "Running flake8 linting..."
	$(PYTHON) -m flake8 algorithms/ tests/

.PHONY: isort
isort:
	@echo "Running isort to organize imports..."
	$(PYTHON) -m isort algorithms/ tests/

.PHONY: lint
lint: isort black mypy flake8
	@echo "All linting steps completed."

.PHONY: install-dev
install-dev:
	@echo "Installing development dependencies with UV..."
	uv pip install -e ".[dev]"

.PHONY: install-mcp
install-mcp:
	@echo "Installing MCP CLI with UV..."
	uv pip install "mcp[cli]"
