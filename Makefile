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
AWK_CMD := $(shell command -v gawk || command -v awk)

# Use UV for Python commands
PYTHON := uv run --python=3.11

# Default target
.PHONY: help
help: ## Display this help message
	@echo "Available targets:"
	@awk -F: '/^[a-z-]+:/ {print "  "$$1}' Makefile

# Build the Docker image
.PHONY: build
build: ## Build the Docker/Podman image
	@echo "Building $(IMAGE_NAME) image..."
	$(DOCKER_CMD) build -t $(IMAGE_NAME) .

# Run the container
.PHONY: run
run: ## Start container with mounted volumes
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
stop: ## Stop and remove the container
	@echo "Stopping $(CONTAINER_NAME) container..."
	$(DOCKER_CMD) stop $(CONTAINER_NAME) || true
	$(DOCKER_CMD) rm $(CONTAINER_NAME) || true

# Test MCP servers
.PHONY: test
test: test-python README.md ## Run tests and verify MCP servers
	@echo "Testing MCP servers..."
	$(DOCKER_CMD) exec $(CONTAINER_NAME) /home/mcp/scripts/mcp-python-test.sh

# Analyze algorithm
.PHONY: analyze
analyze: ## Run analysis via MCP (usage: make analyze ALGO=fibonacci)
	@if [ -z "$(ALGO)" ]; then \
		echo "Error: ALGO not specified"; \
		echo "Usage: make analyze ALGO=fibonacci"; \
		exit 1; \
	fi
	@echo "Analyzing $(ALGO)..."
	$(DOCKER_CMD) exec $(CONTAINER_NAME) /home/mcp/scripts/analyze-with-claude.sh $(ALGO)

# Analyze with Claude directly
.PHONY: claude-analyze
claude-analyze: ## Run algorithm analysis with local Claude Code (usage: make claude-analyze ALGO=fibonacci)
	@if [ -z "$(ALGO)" ]; then \
		echo "Error: ALGO not specified"; \
		echo "Usage: make claude-analyze ALGO=fibonacci"; \
		exit 1; \
	fi
	@echo "Analyzing $(ALGO) with Claude Code..."
	claude-code analyze --code "$$(cat algorithms/$(ALGO).py)" --output analysis_results/$(ALGO)_claude.md

# Clean up
.PHONY: clean
clean: stop ## Remove container and image
	@echo "Removing $(IMAGE_NAME) image..."
	$(DOCKER_CMD) rmi $(IMAGE_NAME) || true
	@echo "Cleanup complete"

# Generate directories
.PHONY: dirs
dirs: ## Create required directories
	@mkdir -p algorithms
	@mkdir -p scripts
	@mkdir -p analysis_results
	@mkdir -p emacs
	@mkdir -p data/{memory,filesystem,github}
	@mkdir -p .claude
	@mkdir -p .vscode

# Tangle org files to generate config files
.PHONY: tangle
tangle: ## Generate config files from org files
	@echo "Tangling org files to generate config files..."
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-tangle-file "env-setup.org")'
	@echo "Tangling complete. Config files generated."

# Detangle - update org files from modified configs
.PHONY: detangle
detangle: ## Update org files from modified configs
	@echo "Detangling configs back into org files..."
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle ".dir-locals.el")'
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle "emacs/mcp-helpers.el")'
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle ".claude/preferences.json")'
	@emacs --batch --eval "(require 'org)" --eval '(org-babel-detangle ".vscode/settings.json")'
	@echo "Detangling complete. Org files updated."

# Python testing and development targets
.PHONY: pytest
pytest: README.md ## Run all tests with pytest
	@echo "Running pytest..."
	$(PYTHON) -m pytest tests/ $(PYTEST_ARGS)

.PHONY: test-python
test-python: .venv ## Run Python tests with UV
	@echo "Running Python tests with UV..."
	@. .venv/bin/activate && python -m pytest tests/ -v

.venv:
	@echo "Creating virtual environment..."
	@uv venv .venv
	@. .venv/bin/activate && uv pip install pytest

.PHONY: pytest-verbose
pytest-verbose: README.md ## Run tests with verbose output
	@echo "Running pytest in verbose mode..."
	$(PYTHON) -m pytest tests/ -v $(PYTEST_ARGS)

# Ensure venv exists
.PHONY: ensure-venv
ensure-venv: ## Create Python virtual environment with uv
	@if [ ! -d ".venv" ]; then \
		echo "Creating virtual environment..."; \
		uv venv .venv; \
	fi

# Install development tools
.PHONY: install-dev-tools
install-dev-tools: ensure-venv ## Install development tools (flake8, black, mypy)
	@echo "Installing development tools..."
	@uv pip install flake8 black mypy
	@echo "Development tools installed."

.PHONY: install-dev
install-dev: ## Install development dependencies with UV
	@echo "Installing development dependencies with UV..."
	uv pip install -e ".[dev]"

.PHONY: install-mcp
install-mcp: ## Install MCP CLI with UV
	@echo "Installing MCP CLI with UV..."
	uv pip install "mcp[cli]"

# Python linting with flake8 via uv
.PHONY: lint
lint: install-dev-tools ## Run flake8 linter on Python code
	@echo "Linting Python code..."
	@.venv/bin/flake8 algorithms/ tests/
	@echo "Lint complete."

# Format Python code with Black
.PHONY: format
format: install-dev-tools ## Format Python code with Black
	@echo "Formatting Python code..."
	@.venv/bin/black algorithms/ tests/
	@echo "Format complete."

.PHONY: isort
isort: install-dev-tools ## Sort imports with isort
	@echo "Running isort to organize imports..."
	@.venv/bin/isort algorithms/ tests/
	@echo "Import sorting complete."

# Type check Python code with mypy
.PHONY: typecheck
typecheck: install-dev-tools ## Run mypy type checking
	@echo "Running type checks..."
	@.venv/bin/mypy --config-file mypy.ini --namespace-packages --explicit-package-bases algorithms/*.py tests/*.py
	@echo "Type check complete."

.PHONY: check-all
check-all: lint format typecheck ## Run all checks (lint, format, typecheck)
	@echo "All checks completed."

.PHONY: check-secrets
check-secrets: ## Check for required secrets and set up .env file
	@if [ ! -f ".env" ]; then \
		echo "No .env file found. Checking for GitHub auth..."; \
		if gh auth status &>/dev/null; then \
			./get_secrets.sh; \
		else \
			echo "Error: No .env file and GitHub CLI not authenticated."; \
			echo "Either:"; \
			echo "  1. Run 'gh auth login' and then 'make check-secrets' again"; \
			echo "  2. Create a .env file manually based on .envrc.example"; \
			exit 1; \
		fi; \
	else \
		echo ".env file found, using existing secrets"; \
	fi

list-mcp-tools: ## List MCP tools from the Pydantic Python server
	@echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq

mcp-tools: ## List MCP tools with prettier formatting
	@echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | \
	jq '.result.tools[] | {name, description}'

add: ## Simple addition example using MCP run-python
	@echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "input": {"python_code": "print(40 + 2)"}}, "id": 2}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq '.result.output.stdout'

list-mcp-resources: ## List available MCP resources
	@echo '{"jsonrpc": "2.0", "method": "resources/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq

list-mcp-prompts: ## List available MCP prompts
	@echo '{"jsonrpc": "2.0", "method": "prompts/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq

README.md: README.org ## Generate Markdown for PyPi and uv
	emacs --batch -l org --eval "(progn (find-file \"README.org\") (org-md-export-to-markdown))"
