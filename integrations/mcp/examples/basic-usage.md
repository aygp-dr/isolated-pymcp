# Basic MCP Usage Examples

This document provides simple examples of using the Model Context Protocol (MCP) for code execution and other operations in isolated environments.

## Running Python Code

### Using the CLI

```bash
# Start the MCP Run Python server
source integrations/mcp/environments/shell-helpers.sh
start_mcp_server runpython

# Run a simple Python calculation
run_python "result = 2 + 2; print(f'The answer is {result}'); result"
```

### Using VS Code

1. Install the MCP extension (if available)
2. Configure the extension using the settings in `integrations/mcp/environments/vscode.json`
3. Create a new file with Python code
4. Use the command palette to run the code with MCP

### Using Emacs

```elisp
;; Load the MCP Emacs integration
(require 'mcp)

;; Start the MCP Run Python server
(mcp-start-server 'run-python)

;; Run some Python code
(mcp-run-python-code "result = 2 + 2; print(f'The answer is {result}'); result")
```

## Using the Memory Server

The Memory server provides a key-value store that persists for the session lifetime:

```bash
# Start the MCP Memory server
start_mcp_server memory

# Use curl to store a value
curl -X POST http://localhost:3002 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0", 
    "method": "tools/call", 
    "params": {
      "name": "memory_store", 
      "arguments": {
        "key": "example_key", 
        "value": "example_value"
      }
    }, 
    "id": 1
  }'

# Use curl to retrieve the value
curl -X POST http://localhost:3002 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0", 
    "method": "tools/call", 
    "params": {
      "name": "memory_retrieve", 
      "arguments": {
        "key": "example_key"
      }
    }, 
    "id": 2
  }'
```

## Using the Filesystem Server

The Filesystem server provides sandboxed file operations:

```bash
# Start the MCP Filesystem server
start_mcp_server filesystem

# List files in the current directory
curl -X POST http://localhost:3003 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0", 
    "method": "tools/call", 
    "params": {
      "name": "list_directory", 
      "arguments": {
        "path": "."
      }
    }, 
    "id": 1
  }'
```
