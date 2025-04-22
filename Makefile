# Makefile for isolated-pymcp
# Author: Aidan Pace (apace@defrecord.com)

# Include environment variables if .envrc exists
-include .envrc

# Default variables if not set in .envrc
CONTAINER_NAME ?= isolated-pymcp
IMAGE_NAME ?= isolated-pymcp
REVIEWER_ROLE ?=
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
	@echo "make review-pr PR=x [ROLE=role] [AUTO_MERGE=--auto-merge] - Review PR with optional role"
	@echo "make help           - Show this help"

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

# Review PR
.PHONY: review-pr
review-pr:
	@if [ -z "$(PR)" ]; then \
		echo "Error: PR not specified"; \
		echo "Usage: make review-pr PR=123 [ROLE=engineer|manager|sre|director] [AUTO_MERGE=--auto-merge]"; \
		exit 1; \
	fi
	@echo "Reviewing PR #$(PR)..."
	@if [ -n "$(ROLE)" ]; then \
		./scripts/review-pr.sh $(PR) $(AUTO_MERGE) --reviewer=$(ROLE); \
	else \
		./scripts/review-pr.sh $(PR) $(AUTO_MERGE); \
	fi
