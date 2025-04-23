# Makefile for MCP Emacs Integration

# Variables
SCRIPT_DIR := $(shell pwd)
EMACS_DIR := $(HOME)/.emacs.d/lisp
EMACS := emacs
INTEGRATIONS_DIR := ../../integrations/mcp

# Default target
.PHONY: help
help: ## Display this help message
	@echo "MCP Emacs Integration Makefile"
	@echo "-------------------------------"
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: setup
setup: check-deps ## Set up MCP Emacs integration
	@echo "Setting up MCP Emacs integration..."
	@mkdir -p $(EMACS_DIR)
	@cp $(INTEGRATIONS_DIR)/environments/emacs.el $(EMACS_DIR)/mcp.el
	@chmod +x check-dependencies.sh setup-mcp.sh
	@echo "Tangling code from README.org..."
	@$(EMACS) --batch -l org --eval "(progn (find-file \"README.org\") (org-babel-tangle))"
	@echo "Setup complete. Add to your Emacs config:"
	@echo "(add-to-list 'load-path \"~/.emacs.d/lisp/\")"
	@echo "(require 'mcp)"

.PHONY: check-deps
check-deps: ## Check for required dependencies
	@echo "Checking dependencies..."
	@./check-dependencies.sh

.PHONY: clean
clean: ## Clean up generated files
	@echo "Cleaning up generated files..."
	@find examples -type f \( -name "*.el" -o -name "*.org" -o -name "*.py" \) -delete
	@rm -f init-mcp.el org-babel-setup.el troubleshooting.el
	@echo "Cleanup complete."

.PHONY: tangle
tangle: ## Tangle all code blocks from README.org
	@echo "Tangling code from README.org..."
	@$(EMACS) --batch -l org --eval "(progn (find-file \"README.org\") (org-babel-tangle))"
	@echo "Tangling complete."

.PHONY: start-servers
start-servers: ## Start all MCP servers
	@echo "Starting MCP servers..."
	@if command -v deno >/dev/null 2>&1; then \
		deno run -N -R=node_modules -W=node_modules --node-modules-dir=auto \
		--allow-read=. jsr:@pydantic/mcp-run-python stdio > /tmp/mcp-runpython.log 2>&1 & \
		echo "Started Python server (PID: $$!)"; \
	else \
		echo "Deno not found. Cannot start Python server."; \
		exit 1; \
	fi
	@if command -v npx >/dev/null 2>&1; then \
		npx -y @modelcontextprotocol/server-memory > /tmp/mcp-memory.log 2>&1 & \
		echo "Started Memory server (PID: $$!)"; \
		npx -y @modelcontextprotocol/server-filesystem > /tmp/mcp-filesystem.log 2>&1 & \
		echo "Started Filesystem server (PID: $$!)"; \
		npx -y @modelcontextprotocol/server-github > /tmp/mcp-github.log 2>&1 & \
		echo "Started GitHub server (PID: $$!)"; \
	else \
		echo "npx not found. Cannot start MCP servers."; \
		exit 1; \
	fi

.PHONY: stop-servers
stop-servers: ## Stop all MCP servers
	@echo "Stopping MCP servers..."
	@pkill -f "deno run.*jsr:@pydantic/mcp-run-python" || echo "No Python server running"
	@pkill -f "npx.*@modelcontextprotocol/server-memory" || echo "No Memory server running"
	@pkill -f "npx.*@modelcontextprotocol/server-filesystem" || echo "No Filesystem server running" 
	@pkill -f "npx.*@modelcontextprotocol/server-github" || echo "No GitHub server running"
	@echo "All servers stopped."

.PHONY: test
test: ## Run a simple test of MCP integration
	@echo "Testing MCP integration..."
	@$(EMACS) --batch -l $(EMACS_DIR)/mcp.el --eval "(progn \
		(message \"Testing MCP Python server...\") \
		(require 'mcp) \
		(let ((result (mcp-call-function 'run-python \"tools/list\" nil))) \
		  (if result \
		      (message \"Success: MCP server responded\") \
		    (message \"Error: Failed to communicate with MCP server\"))))"
	@echo "Test complete."