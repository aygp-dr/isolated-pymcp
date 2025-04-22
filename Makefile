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

# Default target
.PHONY: help
help:
	@echo "isolated-pymcp Makefile"
	@echo "---------------------"
	@echo "make build          - Build the Docker image"
	@echo "make run            - Run the container"
	@echo "make stop           - Stop the container"
	@echo "make test           - Test MCP servers"
	@echo "make analyze ALGO=x - Analyze algorithm x"
	@echo "make clean          - Remove containers and images"
	@echo "make tangle         - Generate config files from org sources"
	@echo "make detangle       - Update org files from modified configs"
	@echo "make lint           - Run linting tools on code"
	@echo "make format         - Format code with Black"
	@echo "make typecheck      - Run type checking with mypy"
	@echo "make help           - Show this help"

# Build the Docker image
.PHONY: build
build:
	@echo "Building $(IMAGE_NAME) image..."
	$(DOCKER_CMD) build -t $(IMAGE_NAME) .

# Run the container
.PHONY: run
run: check-secrets
	@echo "Running $(CONTAINER_NAME) container..."
	$(DOCKER_CMD) run -d --name $(CONTAINER_NAME) \
		--env-file .env \
		-p 127.0.0.1:$(MCP_RUNPYTHON_PORT):$(MCP_RUNPYTHON_PORT) \
		-p 127.0.0.1:$(MCP_MEMORY_PORT):$(MCP_MEMORY_PORT) \
		-p 127.0.0.1:$(MCP_FILESYSTEM_PORT):$(MCP_FILESYSTEM_PORT) \
		-p 127.0.0.1:$(MCP_GITHUB_PORT):$(MCP_GITHUB_PORT) \
		-p 127.0.0.1:$(MCP_MULTILSPY_PORT):$(MCP_MULTILSPY_PORT) \
		-p 127.0.0.1:$(MCP_PYTHONLSP_PORT):$(MCP_PYTHONLSP_PORT) \
		-v $(PWD)/algorithms:/home/mcp/algorithms \
		-v $(PWD)/analysis_results:/home/mcp/analysis_results \
		--memory=1g \
		--cpus=2 \
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

README.md: README.org ## uv supported README format + publish support
	emacs --batch -l org --eval "(progn (find-file \"README.org\") (org-md-export-to-markdown))"

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

# Ensure venv exists
.PHONY: ensure-venv
ensure-venv:
	@if [ ! -d ".venv" ]; then \
		echo "Creating virtual environment..."; \
		uv venv .venv; \
	fi

# Install development tools
.PHONY: install-dev-tools
install-dev-tools: ensure-venv
	@echo "Installing development tools..."
	@uv pip install flake8 black mypy
	@echo "Development tools installed."

# Python linting with flake8 via uv
.PHONY: lint
lint: install-dev-tools
	@echo "Linting Python code..."
	@.venv/bin/flake8 algorithms/ tests/
	@echo "Lint complete."

# Format Python code with Black
.PHONY: format
format: install-dev-tools
	@echo "Formatting Python code..."
	@.venv/bin/black algorithms/ tests/
	@echo "Format complete."

# Type check Python code with mypy
.PHONY: typecheck
typecheck: install-dev-tools
	@echo "Running type checks..."
	@.venv/bin/mypy --config-file mypy.ini --namespace-packages --explicit-package-bases algorithms/*.py tests/*.py
	@echo "Type check complete."

# Run all checks - lint, format and typecheck
.PHONY: check-all
check-all: lint format typecheck
	@echo "All checks completed."

# Test MCP with sample payloads
.PHONY: test-mcp-basic
test-mcp-basic:
	@echo "Testing basic MCP functionality with minimal payload..."
	@curl -s -X POST "http://localhost:$(MCP_RUNPYTHON_PORT)/execute" \
		-H "Content-Type: application/json" \
		-d @tests/payloads/minimal_request.json | jq

# Test MCP with complex payloads
.PHONY: test-mcp-complex
test-mcp-complex:
	@echo "Testing MCP with more complex file requests..."
	@curl -s -X POST "http://localhost:$(MCP_RUNPYTHON_PORT)/execute" \
		-H "Content-Type: application/json" \
		-d @tests/payloads/fib_files_request.json | jq

# Check for required secrets and set up .env file
.PHONY: check-secrets
check-secrets:
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


# Target to list MCP tools from the Pydantic Python server
list-mcp-tools:
	@echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq

# Alternative with prettier formatting
mcp-tools:
	@echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | \
	jq '.result.tools[] | {name, description}'

# Simple addition example
add:
	@echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "input": {"python_code": "print(40 + 2)"}}, "id": 2}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq '.result.output.stdout'

# List available resources
list-mcp-resources:
	@echo '{"jsonrpc": "2.0", "method": "resources/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq

# List available prompts
list-mcp-prompts:
	@echo '{"jsonrpc": "2.0", "method": "prompts/list", "id": 1}' | \
	deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
	--allow-read=$(CURDIR) jsr:@pydantic/mcp-run-python stdio | jq
