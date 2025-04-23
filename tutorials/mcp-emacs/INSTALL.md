# Installing MCP Emacs Integration

This guide walks you through the installation and setup of the MCP Emacs integration for isolated Python execution.

## Prerequisites

Before installing, ensure you have:

- Emacs 27.1 or newer
- Deno (for Python execution)
- Node.js and npm (for other MCP servers)
- The 'request' Emacs package

## Installation Steps

### 1. Check Dependencies

Run the dependency checker to ensure all required software is installed:

```bash
./check-dependencies.sh
```

### 2. Setup MCP Integration

Run the setup script to install the MCP Emacs package and configurations:

```bash
./setup-mcp.sh
```

This will:
- Create necessary directories
- Copy the MCP Emacs package to your `~/.emacs.d/lisp/` directory
- Copy MCP server configurations to `~/mcp/config/`
- Tangle code from the README.org file

### 3. Update Emacs Configuration

Add the following to your Emacs configuration file (`~/.emacs`, `~/.emacs.d/init.el`, or similar):

```elisp
;; Add mcp.el to load path
(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'mcp)

;; Set timeout for MCP operations (optional)
(setq mcp-default-timeout 30000)  ;; 30 seconds

;; Enable org-babel support for MCP Python (optional)
(with-eval-after-load 'org
  (add-to-list 'org-babel-load-languages '(mcp-python . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))
```

### 4. Using the Makefile (Alternative)

Alternatively, you can use the included Makefile to set up and manage the MCP integration:

```bash
# Setup everything
make setup

# Check dependencies only
make check-deps

# Start all MCP servers
make start-servers

# Stop all MCP servers
make stop-servers

# Clean generated files
make clean
```

## Testing the Installation

To test that the installation was successful:

1. Open Emacs
2. Execute the following Emacs Lisp code:

```elisp
(mcp-start-server 'run-python)
(mcp-run-python-code "print('Hello from MCP Python!'); 2 + 2")
```

If successful, you should see output in the `*mcp-result*` buffer.

## Troubleshooting

If you encounter issues:

1. Check that all dependencies are properly installed
2. Verify that the MCP servers are running
3. Check the `*mcp-server-name*` buffers for error messages
4. Try running `make test` to verify server communication

For more detailed diagnostics, use the troubleshooting functions:

```elisp
(load-file "troubleshooting.el")
(my-mcp-check-ports)
(my-mcp-debug-server-commands)
```