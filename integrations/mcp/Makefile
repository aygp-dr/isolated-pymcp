# Makefile for MCP integrations

# Default variables
MCP_BASE_DIR := $(shell pwd)
MCP_RUNPYTHON_PORT ?= 3001
MCP_MEMORY_PORT ?= 3002
MCP_FILESYSTEM_PORT ?= 3003
MCP_GITHUB_PORT ?= 3004

# Check command existence
DENO_CMD := $(shell command -v deno 2>/dev/null)
NPX_CMD := $(shell command -v npx 2>/dev/null)
UVX_CMD := $(shell command -v uvx 2>/dev/null)

# Default target
.PHONY: help
help: ## Display this help message
	@echo "MCP Integration Makefile"
	@echo "-------------------------"
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Setup targets
.PHONY: setup-all
setup-all: setup-vscode setup-emacs setup-shell setup-claude ## Set up all environments

.PHONY: setup-vscode
setup-vscode: ## Set up VS Code integration
	@echo "Setting up VS Code integration..."
	@mkdir -p .vscode
	@cp environments/vscode.json .vscode/mcp-settings.json
	@echo "VS Code integration set up successfully"

.PHONY: setup-emacs
setup-emacs: ## Set up Emacs integration
	@echo "Setting up Emacs integration..."
	@mkdir -p $(HOME)/.emacs.d/lisp
	@cp environments/emacs.el $(HOME)/.emacs.d/lisp/mcp.el
	@echo "Emacs integration set up successfully"
	@echo "Add this to your Emacs configuration:"
	@echo "(add-to-list 'load-path \"~/.emacs.d/lisp\")"
	@echo "(require 'mcp)"

.PHONY: setup-shell
setup-shell: ## Set up shell integration
	@echo "Setting up shell integration..."
	@cp environments/shell-helpers.sh $(MCP_BASE_DIR)/mcp-shell-helpers.sh
	@chmod +x $(MCP_BASE_DIR)/mcp-shell-helpers.sh
	@echo "Shell integration set up successfully"
	@echo "Use: source $(MCP_BASE_DIR)/mcp-shell-helpers.sh"

.PHONY: setup-claude
setup-claude: ## Set up Claude Desktop and Code integration
	@echo "Setting up Claude integration..."
	@mkdir -p $(MCP_BASE_DIR)/.claude
	@cp environments/claude-desktop.json $(MCP_BASE_DIR)/.claude/mcp-config.json
	@echo "Claude integration set up successfully"

# Server management
.PHONY: start-servers
start-servers: check-dependencies ## Start all MCP servers
	@echo "Starting all MCP servers..."
	@if [ -z "$(DENO_CMD)" ]; then \
		echo "Error: Deno not found. Please install Deno."; \
		exit 1; \
	fi
	@if [ -z "$(NPX_CMD)" ]; then \
		echo "Error: npx not found. Please install Node.js and npm."; \
		exit 1; \
	fi
	@$(DENO_CMD) run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
		--allow-read=$(MCP_BASE_DIR) jsr:@pydantic/mcp-run-python stdio > /tmp/mcp-runpython.log 2>&1 & \
		echo $$! > /tmp/mcp-runpython.pid
	@$(NPX_CMD) -y @modelcontextprotocol/server-memory > /tmp/mcp-memory.log 2>&1 & \
		echo $$! > /tmp/mcp-memory.pid
	@$(NPX_CMD) -y @modelcontextprotocol/server-filesystem > /tmp/mcp-filesystem.log 2>&1 & \
		echo $$! > /tmp/mcp-filesystem.pid
	@$(NPX_CMD) -y @modelcontextprotocol/server-github > /tmp/mcp-github.log 2>&1 & \
		echo $$! > /tmp/mcp-github.pid
	@echo "All MCP servers started successfully"

.PHONY: stop-servers
stop-servers: ## Stop all running MCP servers
	@echo "Stopping all MCP servers..."
	@if [ -f /tmp/mcp-runpython.pid ]; then \
		kill $$(cat /tmp/mcp-runpython.pid) 2>/dev/null || true; \
		rm -f /tmp/mcp-runpython.pid; \
	fi
	@if [ -f /tmp/mcp-memory.pid ]; then \
		kill $$(cat /tmp/mcp-memory.pid) 2>/dev/null || true; \
		rm -f /tmp/mcp-memory.pid; \
	fi
	@if [ -f /tmp/mcp-filesystem.pid ]; then \
		kill $$(cat /tmp/mcp-filesystem.pid) 2>/dev/null || true; \
		rm -f /tmp/mcp-filesystem.pid; \
	fi
	@if [ -f /tmp/mcp-github.pid ]; then \
		kill $$(cat /tmp/mcp-github.pid) 2>/dev/null || true; \
		rm -f /tmp/mcp-github.pid; \
	fi
	@echo "All MCP servers stopped successfully"

# Testing and utilities
.PHONY: check-dependencies
check-dependencies: ## Check required dependencies
	@echo "Checking dependencies..."
	@missing=""
	@if [ -z "$(DENO_CMD)" ]; then missing="$$missing deno"; fi
	@if [ -z "$(NPX_CMD)" ]; then missing="$$missing npm/npx"; fi
	@if [ ! -z "$$missing" ]; then \
		echo "Missing dependencies:$$missing"; \
		echo "Please install the missing dependencies and try again."; \
		exit 1; \
	fi
	@echo "All dependencies are installed"

.PHONY: test-runpython
test-runpython: ## Test the Run Python MCP server
	@echo "Testing Run Python MCP server..."
	@if [ -z "$(DENO_CMD)" ]; then \
		echo "Error: Deno not found. Please install Deno."; \
		exit 1; \
	fi
	@echo '{"jsonrpc": "2.0", "method": "tools/call", "params": {"name": "run_python_code", "arguments": {"python_code": "result = 2 + 2\nprint(f\"The answer is: {result}\")\nresult"}}, "id": 1}' | \
	$(DENO_CMD) run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
		--allow-read=$(MCP_BASE_DIR) jsr:@pydantic/mcp-run-python stdio
	@echo "Run Python test completed"

.PHONY: test-memory
test-memory: ## Test the Memory MCP server
	@echo "Testing Memory MCP server..."
	@if [ -z "$(NPX_CMD)" ]; then \
		echo "Error: npx not found. Please install Node.js and npm."; \
		exit 1; \
	fi
	@echo '{"jsonrpc": "2.0", "method": "tools/list", "id": 1}' | \
	$(NPX_CMD) -y @modelcontextprotocol/server-memory
	@echo "Memory test completed"

.PHONY: test-all
test-all: test-runpython test-memory ## Test all MCP servers

# Clean up
.PHONY: clean
clean: stop-servers ## Clean up temporary files
	@echo "Cleaning up..."
	@rm -f /tmp/mcp-*.log
	@echo "Cleanup complete"
